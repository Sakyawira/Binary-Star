extends RefCounted
## Authoring contracts kept independently of the compiled Ink data.

const CONFLICT_FIRST_OPTIONS := [
	"I’m glad you had time with your friends. I just wish we’d had a little time for us, too.",
	"I don’t want you to give them up. I want us to choose a time we can actually keep.",
	"We can get things wrong and still want to be here. I love you, sayang.",
	"I know, and it mattered. I want you to understand why it still hurt.",
	"We can slow down. I want to understand you, too.",
	"If one of us can’t make the call, we say so. Then we pick a time and keep it.",
]
const CONFLICT_DELTAS := [[1, 0, -1], [0, 1, -1], [1, 0, -1], [0, 1, -1], [1, 0, -1], [1, 0, -1]]
const ENDING_TITLES := {"closer": "A little closer", "reaching": "Still reaching", "distance": "A quiet distance"}

static func expected_opening(route: Array) -> Array:
	var opening: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/expected_opening.json"))
	var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/expected_story.json"))
	var result: Array = [opening.opening_prompt]
	result.append_array(opening.opening_responses[route[0]])
	result.append(opening.day_prompt_after_unwell if route[0] == 1 else opening.day_prompt)
	result.append_array(opening.day_responses[route[1]])
	result.append_array(opening.doctor_and_topic)
	result.append_array(opening.topic_responses[route[2]])
	if route[2] != 0:
		result.append_array(opening.support_responses[route[3]])
		if route[3] != 0:
			result.append_array(opening.reassurance)
		# All support routes rejoin at "I just really miss you".
		result.append_array(original.main.slice(5, 10))
		result.append_array(opening.return_to_astronaut)
	# The authored opening and shared binary-star conversation remain exact.
	# The new conflict is checked below by its decisions, outcomes, and pacing.
	result.append_array(original.main.slice(13, 28))
	var whitespace := RegEx.create_from_string("[ \\t]+")
	for entry in result:
		entry.text = whitespace.sub(entry.text, " ", true)
	return result


static func run(root: Window, verify: Callable) -> void:
	var controller := StoryController.new()
	root.add_child(controller)
	var output := {"lines": [], "phases": [], "phase_choices": [], "phase_lines": [], "totals": [], "committed": 0}
	controller.line_ready.connect(func(text, tags): output.lines.append({"text": text, "tags": tags}))
	controller.phase_changed.connect(func(phase):
		output.phases.append(phase)
		output.phase_choices.append(output.committed)
		output.phase_lines.append(output.lines.size())
	)
	controller.finished.connect(func(): output.totals.append(controller.aneska_empathy))
	controller.failed.connect(func(message): verify.call(false, "Live story Ink error: " + message))
	var routes: Array = []
	for opening in 3:
		for day in 3:
			routes.append([opening, day, 0])
			for topic in [1, 2]:
				for support in 3:
					routes.append([opening, day, topic, support])
	verify.call(routes.size() == 63, "All 63 authored opening routes are covered")
	var endings_seen: Dictionary = {}
	var reactions: Dictionary = {}
	for index in routes.size():
		var route: Array = routes[index]
		_reset_output(output)
		controller.start()
		verify.call(controller.aneska_empathy == 0 and controller.ending_title.is_empty(), "Restart resets empathy and the ending title")
		verify.call(controller.story.variables_state.get_variable("aneska_explained_tiredness") == false, "Restart forgets the previous route's tiredness disclosure")
		var choices := route.duplicate()
		for decision in 6:
			choices.append(index % 3)
		_play(controller, choices, 0, route.size(), output, reactions, verify)
		var expected := expected_opening(route)
		verify.call(output.lines.slice(0, expected.size()) == expected, "Authored opening words, tags, and joins are preserved: %s" % [route])
		_check_continuity(output.lines, route, verify)
		endings_seen[controller.story.variables_state.get_variable("ending_id")] = true
	verify.call(endings_seen.size() == 3, "All three resolutions are reachable through real complete playthroughs")
	# Exhaust every six-decision conflict sequence. Vary the incoming empathy and
	# whether tiredness was already disclosed, independently of the opening menus.
	for sequence in 729:
		_reset_output(output)
		controller.start()
		var initial_score := sequence % 8 - 4
		controller.story.variables_state.set_variable("aneska_empathy", initial_score)
		controller.story.variables_state.set_variable("aneska_explained_tiredness", sequence % 2 == 0)
		controller.story.choose_path_string("energy_and_attention")
		var choices: Array = []
		var encoded := sequence
		for decision in 6:
			choices.append(encoded % 3)
			encoded = int(encoded / 3)
		_play(controller, choices, initial_score, 0, output, reactions, verify)
	for stage in 6:
		verify.call(reactions[stage].size() == 3, "Each conflict choice has three distinct immediate Aneska reactions")
	for score in [-1, 0, 4, 5]:
		_reset_output(output)
		controller.start()
		controller.story.variables_state.set_variable("aneska_empathy", score)
		controller.story.choose_path_string("resolve_conversation")
		for step in 30:
			if controller.ended:
				break
			controller.advance()
		_check_ending(controller, score, output, verify)
	controller.start()
	verify.call(controller.ending_title.is_empty() and controller.story.variables_state.get_variable("final_empathy") == 0, "Restart clears the resolved ending and final tally")
	controller.queue_free()


static func _reset_output(output: Dictionary) -> void:
	for key in ["lines", "phases", "phase_choices", "phase_lines", "totals"]:
		output[key].clear()
	output.committed = 0


static func _play(controller: StoryController, choices: Array, initial_score: int, opening_count: int, output: Dictionary, reactions: Dictionary, verify: Callable) -> void:
	var score := initial_score
	for step in 180:
		if controller.ended:
			break
		if not controller.story.can_continue and not controller.story.current_choices.is_empty():
			controller.advance()
			verify.call(controller.story.current_choices.size() == 3, "Every decision offers all three tones")
			controller.choose(-1)
			controller.choose(3)
			verify.call(controller.aneska_empathy == score, "Showing choices and invalid input do not score")
			var point: int = output.committed
			if point >= choices.size():
				verify.call(false, "Unexpected extra decision")
				break
			var stage := point - opening_count
			var deltas: Array
			if stage >= 0:
				deltas = CONFLICT_DELTAS[stage]
				verify.call(controller.story.current_choices[0].text.strip_edges() == CONFLICT_FIRST_OPTIONS[stage], "Conflict decisions occur in the intended dramatic order")
				verify.call(controller.phase == ("day" if stage < 4 else "twilight"), "The storm follows the buildup and contains two decisions")
			else:
				deltas = [1, 0, -1] if point < 3 else [0, 1, -1]
			var response: int = choices[point]
			var words: String = controller.story.current_choices[response].text.strip_edges()
			score += deltas[response]
			output.committed += 1
			controller.choose(response)
			verify.call(output.lines[-1].text == "“%s”" % words and output.lines[-1].tags[0] == "Yuvan", "The selected response becomes Yuvan's spoken line")
			verify.call(controller.aneska_empathy == score, "Each committed choice applies its matrix delta once")
			var count: int = output.lines.size()
			controller.choose(response)
			verify.call(controller.aneska_empathy == score and output.lines.size() == count, "Repeated confirmation cannot duplicate a choice")
			controller.advance()
			verify.call(output.lines[-1].tags[0] == "Aneska", "Aneska immediately responds to the chosen tone")
			if stage >= 0:
				if not reactions.has(stage):
					reactions[stage] = {}
				reactions[stage][output.lines[-1].text] = true
		else:
			controller.advance()
		verify.call(controller.aneska_empathy == score, "NPC dialogue and joins leave empathy unchanged")
	verify.call(controller.ended and output.committed == choices.size(), "Every route reaches its resolution without dropping or adding decisions")
	verify.call(output.phases == ["day", "twilight", "evening"], "Every route has one storm and one recovery")
	verify.call(output.phase_choices == [0, opening_count + 4, opening_count + 6], "The background changes at the peak and after the final decision")
	if output.phase_lines.size() == 3:
		verify.call(output.phase_lines[2] - output.phase_lines[1] >= 10, "The storm lasts through a sustained exchange, not two lines")
	_check_ending(controller, score, output, verify)


static func _check_ending(controller: StoryController, score: int, output: Dictionary, verify: Callable) -> void:
	var expected := "closer" if score >= 5 else ("reaching" if score >= 0 else "distance")
	verify.call(controller.story.variables_state.get_variable("ending_id") == expected, "Final cumulative empathy selects the correct resolution")
	verify.call(controller.ending_title == ENDING_TITLES[expected], "The ending has its matching title")
	verify.call(controller.story.variables_state.get_variable("final_empathy") == score, "The resolution retains the exact final tally")
	controller.advance()
	verify.call(controller.ended and output.totals == [score], "Story completion happens once and retains its score")


static func _check_continuity(received: Array, route: Array, verify: Callable) -> void:
	var dialogue: Array[String] = []
	for entry in received:
		dialogue.append(entry.text)
	verify.call(dialogue.count("“So apparently… there’s something called a binary star.”") == 1, "Every route introduces binary stars once")
	verify.call(not dialogue.has("“So - what about you? Any topic for your girlfriend?”"), "The conflict acknowledges the earlier conversation")
	var first_tired := dialogue.count("“Sigh. I'm just realy tired. And I really don't feel like talking right now”")
	var later_tired := dialogue.count("“I know - I am so sorry. I just didn’t feel like I have the energy tonight.”")
	verify.call(first_tired + later_tired == 1, "Aneska explains her tiredness once across all joins")
	if route[0] == 1:
		verify.call(dialogue.has("“Was today that bad?”") and not dialogue.has("“How are you, though?”"), "The check-in remembers Yuvan already feels unwell")
