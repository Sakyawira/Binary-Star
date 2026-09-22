extends SceneTree
## Integration checks against the real scene and serialized signal graph.
## Run: godot --headless --path . --script tests/run_tests.gd
## Render snapshots: godot --path . --script tests/run_tests.gd -- --screenshots

const StoryRoutes := preload("res://tests/story_routes.gd")

var failures: Array[String] = []
var checks := 0
var lines: Array = []
var phases: Array[String] = []
var game: Control
var screenshots := false


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAIL: " + description)


func _run() -> void:
	screenshots = "--screenshots" in OS.get_cmdline_user_args()
	create_timer(180.0).timeout.connect(func():
		printerr("FAIL: Test suite timed out")
		quit(1)
	)
	game = load("res://scenes/main.tscn").instantiate()
	game.get_node("Story").line_ready.connect(func(text, tags): lines.append({"text": text, "tags": tags}))
	game.get_node("Story").phase_changed.connect(func(phase): phases.append(phase))
	game.get_node("Story").failed.connect(func(message): check(false, "Ink error: " + message))
	root.add_child(game)
	await process_frame
	var expected_opening := StoryRoutes.expected_opening([1, 1, 1, 1])
	var smoke_choices := [1, 1, 1, 1, 0, 1, 0, 1, 0, 0]
	check(lines.size() == 1, "First line starts on scene load")
	check(game.dialogue.text == "“Oh my god, what time is it for you?”", "Restored opening starts the conversation")
	check(game.typing, "Typewriter starts")
	_check_dialogue_layout()
	var speaker_y: float = game.speaker.position.y
	check(game.aneska.animation == &"happy", "Speaker tag selects the correct portrait pose")
	_check_portrait_focus("Aneska")
	var first_portrait_texture: Texture2D = game.aneska.texture
	game.aneska._process(0.25)
	check(game.aneska.texture == first_portrait_texture, "Speaker keeps the highlighted sprite throughout typing")
	check(game.audio.voice.playing, "Dialogue-start signal starts typing audio")
	check(game.audio.current_act == 0, "Day signal starts act one")
	game._process(0.13)
	check(game.dialogue.visible_characters >= 2, "Text reveals at the original 65ms cadence")
	await _click()
	check(not game.typing and lines.size() == 1, "Click reveals the current line without skipping it")
	check(is_equal_approx(game.speaker.position.y, speaker_y), "Speaker attribution stays still while text reveals")
	check(game.aneska.animation == &"happy", "Revealing a line returns the speaker to the unhighlighted pose")
	_check_portrait_focus("")
	check(not game.audio.voice.playing, "Dialogue-completed signal stops typing audio")
	await _snapshot("01-calm")
	await _key(KEY_SPACE)
	check(game.choices_box.visible and lines.size() == 1, "Advancing the opening presents Yuvan's choices")
	await _key(KEY_2)
	await _key(KEY_ENTER)
	check(lines.size() == 2 and game.active_speaker == "Yuvan", "Keyboard confirmation begins Yuvan's selected response")
	check(game.history.get_child_count() == 1 and game.history.get_child(0).text == lines[0].text, "Advancing sends the completed line into the crawl")
	_check_portrait_focus("Yuvan")
	await _snapshot("07-yuvan-speaking")
	game._process((game.dialogue.get_total_character_count() + 1) * game.seconds_per_character)
	check(not game.typing, "Natural typewriter completion ends the speaking state")
	_check_portrait_focus("")
	# Four opening decisions and four conflict decisions lead into the climax.
	var choice_number := 1
	for step in 180:
		if game.dialogue.text == "“And I'm scared I only matter when I ask.”":
			break
		game.continue_button.pressed.emit()
		if game.choices_box.visible:
			choice_number += 1
			await process_frame
			await process_frame
			game.choices_box.appearance.custom_step(1.0)
			if choice_number == 3:
				await _snapshot("19-topic-change-choices")
			if choice_number == 4:
				await _snapshot("20-support-choices")
			if choice_number == 5:
				await _snapshot("21-energy-choices")
			if choice_number == 7:
				await _snapshot("22-relationship-choices")
			await _key([KEY_1, KEY_2, KEY_3][smoke_choices[choice_number - 1]])
			await _key(KEY_ENTER)
		_settle_dialogue_handoff()
		check(game.story.phase == "day", "Opening stays in the calm phase")
		_check_dialogue_layout()
		if lines.size() == 3:
			_check_portrait_focus("Aneska")
			await _snapshot("08-aneska-speaking")
		if "I just really miss you" in game.dialogue.text:
			check(game.active_emotion == "neutral" and game.yuvan.animation == &"neutral", "Opening line without an emotion tag uses the neutral pose")
		game.finish_typing()
		if "I went to the Doctor" in game.dialogue.text:
			await _snapshot("02-long-dialogue")
	check(choice_number == 8 and game.story.aneska_empathy == 5, "Player decisions continue through the conflict buildup")
	var before_storm_lines := lines.size()
	game.continue_button.pressed.emit()
	check(phases == ["day", "twilight"] and lines.size() == before_storm_lines + 1, "The storm begins when both characters name their core fears")
	check(game.audio.current_act == 1, "Storm signal starts act two")
	game.stage_tween.custom_step(11.0)
	for background in [game.aneska_background, game.yuvan_background]:
		var first_texture: Texture2D = background.texture
		background._process(0.24)
		check(background.frame_index == 0, "Background waits for the 250ms frame boundary")
		background._process(0.01)
		check(background.frame_index == 1 and background.texture != first_texture, "Background visibly advances through the storm sprites")
	game.aneska_background._process(5.0)
	game.yuvan_background._process(5.0)
	check(game.aneska.size.is_equal_approx(Vector2(231.5, 271)), "Storm signal zooms portraits out")
	check(game.aneska_background.frame_index == 16 and not game.aneska_background.playing, "Storm holds its last frame")
	game.audio.fade.custom_step(2.0)
	check(is_equal_approx(game.audio.players[1].volume_linear, 0.195), "Crossfade reaches original volume")
	check(not game.audio.players[0].playing, "Crossfade stops the previous act")
	game.finish_typing()
	await _snapshot("03-storm")
	for step in 80:
		if game.story.phase == "evening" or game.story.ended:
			break
		game.finish_typing()
		game.advance()
		if game.choices_box.visible:
			choice_number += 1
			await process_frame
			await process_frame
			game.choices_box.appearance.custom_step(1.0)
			await _snapshot("23-storm-choices" if choice_number == 9 else "24-repair-choices")
			await _key([KEY_1, KEY_2, KEY_3][smoke_choices[choice_number - 1]])
			await _key(KEY_ENTER)
		_settle_dialogue_handoff()
		_check_dialogue_layout()
	check(phases == ["day", "twilight", "evening"] and choice_number == 10, "Two decisions remain playable through the storm before recovery")
	check(lines.size() - before_storm_lines >= 12, "The storm sustains a full confrontation and repair exchange")
	check(game.audio.current_act == 2, "End-storm signal starts act three")
	game.stage_tween.custom_step(11.0)
	game.aneska_background._process(5.0)
	check(game.aneska.size.is_equal_approx(Vector2(463, 542)), "End-storm restores portrait size")
	game.yuvan_background._process(5.0)
	check(game.aneska_background.frame_index == 16, "Reverse storm animation completes")
	for background in [game.aneska_background, game.yuvan_background]:
		background.recovery_tween.custom_step(1.1)
		check(background.texture == background.frames.get_frame_texture(&"day", 0), "Recovery returns to the original calm artwork and orientation")
	game.finish_typing()
	await _snapshot("04-after-storm")
	for i in 60:
		if game.story.ended:
			break
		game.finish_typing()
		game.advance()
	check(game.story.ended, "Story reaches END")
	_check_portrait_focus("")
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/expected_story.json"))
	# Ink collapses runs of spaces/tabs in output (the source has a double space
	# in the reconciliation). Keep the source-derived fixture literal and normalize here.
	var whitespace := RegEx.create_from_string("[ \\t]+")
	for route in expected.values():
		for line in route:
			line.text = whitespace.sub(line.text, " ", true)
	check(lines.slice(0, expected_opening.size()) == expected_opening, "The live scene preserves the authored opening and binary-star conversation")
	check(game.story.aneska_empathy == 7 and game.story.ending_title == "A little closer", "The full playthrough reaches the resolution earned by its cumulative choices")
	check(game.ending.visible and game.ending_title.text == "A Little Closer" and lines[-1].text == "“Okay.”", "The ending displays its title and completes its own dialogue")
	check(game.ending_kicker.text == "ENDING UNLOCKED" and not game.hint.visible, "The ending is announced separately from dialogue hints")
	check(game.replay_button.visible, "Story-finished signal shows replay")
	check(not game.continue_button.visible, "Story-finished signal hides continue")
	game.ending_tween.custom_step(0.75)
	check(game.ending.modulate.a > 0.0 and game.ending.modulate.a < 1.0, "The ending reveal fades in gradually")
	game.ending_tween.custom_step(2.0)
	for line in lines:
		check(line.tags.size() in [1, 2] and line.tags[0] in ["Aneska", "Yuvan"], "Speaker and optional emotion tags survive Ink")
	await _snapshot("05-ending")
	await _key(KEY_M)
	check(game.audio.muted and AudioServer.is_bus_mute(0), "Mute input reaches audio through signals")
	await _key(KEY_M)
	check(not game.audio.muted, "Audio can be unmuted")
	game.replay_button.pressed.emit()
	check(game.typing and game.story.phase == "day" and game.audio.current_act == 0, "Replay resets story, stage and audio")
	check(game.dialogue.text == "“Oh my god, what time is it for you?”", "Replay returns to the restored first line")
	check(not game.ending.visible and game.dialogue.modulate.a == 1.0 and game.history.modulate.a == 1.0, "Replay clears the reveal and restores readable dialogue")
	_check_portrait_focus("Aneska")
	game.get_node("Toolbar/Restart").pressed.emit()
	game.finish_typing()
	check(game.history.get_child_count() == 0, "Restart during typing clears dialogue history")
	# Rapid phase changes must cancel old tweens, not leave stale audio or zooms.
	game.story.initiate_storm()
	game.story.end_storm()
	game.story.initiate_storm()
	game.stage_tween.custom_step(11.0)
	game.audio.fade.custom_step(2.0)
	check(game.audio.current_act == 1 and game.aneska.size.x < 240, "Rapid storm signals settle on the latest state")
	# BRANCH2 is retained in Ink, though the original route selector is commented out.
	game.restart()
	game.finish_typing()
	lines.clear()
	game.story.story.choose_path_string("BRANCH2")
	for i in 40:
		game.advance()
		game.finish_typing()
		if game.story.ended:
			break
	check(lines.size() == 22 and game.story.ended, "Dormant BRANCH2 and OUTRO remain playable through Ink")
	check(lines == expected.branch2, "Every alternate-branch line and tag matches the original Ink source transcript")
	# Choice counts are deliberately not fixed at Unity's hard-coded three.
	for count in [1, 2, 4, 9]:
		await _test_choices(count)
	await _test_terminal_choices()
	_test_empathy()
	_test_opening_empathy()
	await _test_portrait_fades()
	await _test_dialogue_history()
	_test_background_recovery()
	await _test_nebula_choice_timing()
	await _test_ending_reveal()
	_test_frames()
	if screenshots:
		game.restart()
		game.finish_typing()
		root.size = Vector2i(960, 540)
		await process_frame
		await _snapshot("06-small-window")
	game.queue_free()
	await process_frame
	await _test_restart_audio_order()
	# Exhaustive synchronous Ink traversal must not inject a long frame into
	# the live typewriter and manually stepped portrait-fade snapshots.
	StoryRoutes.run(root, check)
	await process_frame
	await create_timer(0.1).timeout
	if failures.is_empty():
		print("PASS: %d checks — story, branches, choices, signals, sprites, audio, restart and input." % checks)
	else:
		printerr("FAILED: %d of %d checks" % [failures.size(), checks])
	quit(0 if failures.is_empty() else 1)


func _test_restart_audio_order() -> void:
	# Export can reorder serialized signal handlers. Put audio reset last to
	# reproduce the ordering that silenced music in the release web build.
	var exported_game = load("res://scenes/main.tscn").instantiate()
	var audio_reset := Callable(exported_game.get_node("Audio"), "reset")
	exported_game.restart_requested.disconnect(audio_reset)
	exported_game.restart_requested.connect(audio_reset)
	root.add_child(exported_game)
	await process_frame
	for attempt in 2:
		if attempt == 1:
			exported_game.restart()
		exported_game.finish_typing()
		if exported_game.audio.fade and exported_game.audio.fade.is_valid():
			exported_game.audio.fade.custom_step(2.0)
		check(exported_game.audio.current_act == 0, "Reordered startup starts act one after all resets")
		check(exported_game.audio.players[0].playing, "Reordered startup keeps music playing after dialogue finishes")
		check(is_equal_approx(exported_game.audio.players[0].volume_linear, exported_game.audio.music_volume), "Reordered startup completes the music fade-in on load and replay")
		check(not exported_game.audio.voice.playing, "Music verification excludes typing audio")
	exported_game.queue_free()
	await process_frame


func _test_choices(count: int) -> void:
	# Minimal Ink JSON equivalent to: * [Option N] -> a line, then END.
	var content: Array = []
	var branches := {}
	for i in count:
		content.append_array(["ev", "str", "^Option %d" % i, "/str", "/ev", {"*": "0.c-%d" % i, "flg": 20}])
		branches["c-%d" % i] = ["\n", "^Selected %d" % i, "\n", "end", {"#f": 5}]
	content.append(branches)
	var fixture := JSON.stringify({"inkVersion": 21, "root": [content, "done", null], "listDefs": {}})
	game.restart()
	game.finish_typing()
	game.dialogue.text = ""
	game.story.start(fixture)
	game.story.advance()
	await process_frame
	await process_frame
	check(game.choices_box.visible and game.choices_box.rows.get_child_count() == count, "%d choices render from the choices-ready signal" % count)
	check(game.choices_box.selected_row == 0 and game.choices_box.rows.get_child(0).has_focus(), "Choice menus start with the first response selected and focused")
	check(not game.hint.visible and not game.continue_button.visible, "Choices replace the dialogue advance controls")
	game.story.choose(-1)
	check(game.story.story.current_choices.size() == count, "Invalid choice is safely ignored")
	if count == 4:
		await _key(KEY_UP)
		check(game.choices_box.selected_row == 3, "Up wraps to the last response")
		await _key(KEY_DOWN)
		check(game.choices_box.selected_row == 0, "Down wraps to the first response")
		await _key(KEY_3)
		check(game.choices_box.selected_row == 2 and game.story.story.current_choices.size() == 4, "Number keys select without committing a response")
		await _key(KEY_9)
		check(game.choices_box.selected_row == 2, "Unavailable number shortcuts preserve selection")
		await _key(KEY_END)
		await _key(KEY_ENTER)
		check(game.typing and game.dialogue.visible_characters == 0, "Confirming a choice cannot also reveal the next line")
	elif count == 2:
		var last: Button = game.choices_box.rows.get_child(1)
		var hover := InputEventMouseMotion.new()
		hover.position = root.get_final_transform() * last.get_global_rect().get_center()
		Input.parse_input_event(hover)
		await process_frame
		check(game.choices_box.selected_row == 1, "Hovering a response moves the selection cursor")
		await _click(last.get_global_transform_with_canvas() * (last.size / 2.0))
	elif count == 1:
		var first: Button = game.choices_box.rows.get_child(0)
		var touch := InputEventScreenTouch.new()
		touch.position = root.get_final_transform() * first.get_global_rect().get_center()
		touch.pressed = true
		Input.parse_input_event(touch)
		await process_frame
		touch.pressed = false
		Input.parse_input_event(touch)
		await process_frame
	else:
		await _key(KEY_KP_9)
		await _key(KEY_KP_ENTER)
	check(game.dialogue.text == "Selected %d" % (count - 1), "Choice-button signal chooses the corresponding Ink branch")
	_check_portrait_focus("")
	check(not game.choices_box.visible, "Choosing hides the choice UI")
	game.finish_typing()
	game.advance()
	check(game.story.ended, "Choice branch reaches END")
	await process_frame


func _test_terminal_choices() -> void:
	game.restart()
	game.finish_typing()
	game.dialogue.text = ""
	game.story.start(FileAccess.get_file_as_string("res://tests/fixtures/choice_preview.json"))
	game.story.advance()
	game.finish_typing()
	game.advance()
	await process_frame
	await process_frame
	game.choices_box.appearance.custom_step(1.0)
	await _snapshot("15-terminal-choices")
	await _key(KEY_DOWN)
	check(game.choices_box.selected_row == 1, "Arrow navigation updates the visible response cursor")
	await _snapshot("16-terminal-choices-selected")
	await _key(KEY_ENTER)
	check("I'm not feeling that great" in game.dialogue.text, "Terminal confirmation selects the authored vulnerable reply")
	check(game.story.aneska_empathy == 0, "Warm prompt with a vulnerable response preserves neutral empathy")
	check(not game.choices_box.visible and game.hint.visible, "Confirmation restores dialogue controls")
	game.finish_typing()
	var choices: Array = []
	for index in 12:
		choices.append({"index": index, "text": "Tell me more about the two stars, and how they keep finding their way back to each other even when the universe feels so enormous." if index == 0 else "Stay and listen a little longer. Response %d." % (index + 1)})
	game._show_choices(choices)
	for frame in 5:
		await process_frame
	game.choices_box.appearance.custom_step(1.0)
	var first_row: Button = game.choices_box.rows.get_child(0)
	check(first_row.size.y > 58.0, "Long responses wrap with enough row height")
	check(game.choices_box.scroll.scroll_vertical == 0, "A wrapped first response remains visible after the menu lays out")
	check(game.choices_box.position.y + game.choices_box.size.y < 1020.0, "Many responses stay within the game canvas")
	await _snapshot("17-terminal-choices-wrapped")
	await _key(KEY_END)
	await process_frame
	check(game.choices_box.selected_row == 11 and game.choices_box.scroll.scroll_vertical > 0, "Keyboard navigation scrolls long menus to the selected response")
	if screenshots:
		var window_size := root.size
		root.size = Vector2i(960, 540)
		await process_frame
		await _snapshot("18-terminal-choices-small-window")
		root.size = window_size
		await process_frame
	game.restart()
	check(not game.choices_box.visible and game.choices_box.rows.get_child_count() == 0, "Restart clears the selected response and every choice row")
	game.finish_typing()
	await _key(KEY_ENTER)
	check(game.choices_box.visible, "Dialogue keyboard input opens the live choices after restart")
	await _key(KEY_ENTER)
	check(game.active_speaker == "Yuvan", "Dialogue keyboard input works again after closing a choice menu")


func _test_empathy() -> void:
	var controller := StoryController.new()
	root.add_child(controller)
	var received: Array[String] = []
	var changes: Array[int] = []
	var final_totals: Array[int] = []
	controller.line_ready.connect(func(text, _tags): received.append(text))
	controller.empathy_changed.connect(func(value): changes.append(value))
	controller.finished.connect(func(): final_totals.append(controller.aneska_empathy))
	controller.failed.connect(func(message): check(false, "Empathy fixture error: " + message))
	var fixture := FileAccess.get_file_as_string("res://tests/fixtures/empathy.json")
	var initial_responses := ["A response to listening.", "A neutral response.", "A response to dismissal."]
	var later_responses := {-1: "A guarded follow-up.", 0: "A neutral follow-up.", 1: "An empathic follow-up."}
	# Independent contract for the author's approved nine tone combinations.
	var matrix := [[1, 0, -1], [1, 0, -1], [0, 1, -1]]
	var tones := ["warm", "vulnerable", "frustrated"]
	for prompt_index in 3:
		for response_index in 3:
			received.clear()
			changes.clear()
			final_totals.clear()
			controller.start(fixture)
			controller.story.variables_state.set_variable("test_prompt_tone", tones[prompt_index])
			check(controller.aneska_empathy == 0 and changes == [0], "Each playthrough starts at neutral empathy")
			controller.advance()
			controller.advance()
			controller.advance()
			controller.choose(-1)
			check(controller.aneska_empathy == 0 and changes == [0], "Generating choices, redisplaying them, and invalid input do not score empathy")
			controller.choose(response_index)
			var expected_empathy: int = matrix[prompt_index][response_index]
			check(received[-1] == initial_responses[response_index], "Each choice has its own immediate response")
			check(controller.aneska_empathy == expected_empathy, "%s → %s scores %d" % [tones[prompt_index], tones[response_index], expected_empathy])
			check(changes == ([0] if expected_empathy == 0 else [0, expected_empathy]), "Game observers receive an empathy change once per scored choice")
			controller.choose(response_index)
			check(controller.aneska_empathy == expected_empathy and received.size() == 2, "Repeating a committed selection cannot score or advance it twice")
			controller.advance()
			check(received[-1] == "A shared beat." and controller.aneska_empathy == expected_empathy, "Empathy survives branches rejoining")
			controller.advance()
			controller.choose(0)
			check(received[-1] == later_responses[expected_empathy], "Later dialogue uses the remembered empathy level")
			controller.advance()
			controller.choose(1)
			check(received[-1] == "Final empathy: %d." % expected_empathy, "The final story passage can read the accumulated score")
			controller.advance()
			controller.advance()
			check(controller.ended and final_totals == [expected_empathy], "The final total is retained and story completion fires once")
	controller.start(fixture)
	controller.advance()
	controller.advance()
	controller.choose(2)
	controller.advance()
	controller.advance()
	controller.choose(0)
	controller.advance()
	controller.choose(0)
	check(controller.aneska_empathy == 0, "A vulnerable response to frustration can recover negative empathy to neutral")
	controller.advance()
	controller.choose(0)
	check(controller.aneska_empathy == 1, "Further scored choices accumulate above neutral")
	var previous_story: InkStory = controller.story
	controller.start()
	check(controller.aneska_empathy == 0, "Restarting the novel resets empathy to neutral")
	var change_count := changes.size()
	previous_story.variables_state.set_variable("aneska_empathy", -10)
	check(changes.size() == change_count and controller.aneska_empathy == 0, "A discarded story cannot affect the current playthrough's empathy")
	controller.queue_free()


func _test_opening_empathy() -> void:
	var fixture := FileAccess.get_file_as_string("res://tests/fixtures/choice_preview.json")
	var aneska_replies: Array[String] = []
	for index in 3:
		game.restart()
		game.finish_typing()
		game.dialogue.text = ""
		game.story.start(fixture)
		game.story.advance()
		game.finish_typing()
		game.advance()
		var selected_text: String = game.choices_box.options[index].text
		game.choices_box.rows.get_child(index).pressed.emit()
		var expected_empathy: int = [1, 0, -1][index]
		check(game.story.aneska_empathy == expected_empathy, "Opening terminal choice applies the shared matrix")
		check(selected_text in game.dialogue.text and game.active_speaker == "Yuvan", "The selected opening words become Yuvan's dialogue")
		game.finish_typing()
		game.advance()
		game.finish_typing()
		check(game.active_speaker == "Aneska" and not aneska_replies.has(game.dialogue.text), "Each opening choice receives a different Aneska draft reply")
		aneska_replies.append(game.dialogue.text)
		game.advance()
		check(game.story.ended and game.story.aneska_empathy == expected_empathy, "Reading both replies preserves the total through the end of the preview")
	game.restart()
	check(game.story.aneska_empathy == 0, "Restarting after the opening preview resets its score")


func _check_portrait_focus(character: String) -> void:
	_settle_dialogue_handoff()
	_settle_portrait_fades()
	for portrait in [game.aneska, game.yuvan]:
		var active: bool = portrait.character_name == character
		var expected_folder := "/Characters/%s/" % portrait.character_name.to_upper()
		check(expected_folder in portrait.texture.resource_path, "Portrait artwork matches %s" % portrait.character_name)
		if active:
			check(is_equal_approx(portrait.highlight_amount, 1.0), "Speaking fades to the fully highlighted portrait")
			var highlighted: Texture2D = portrait.material.get_shader_parameter("highlighted_texture")
			if portrait.character_name == "Aneska" and portrait.animation in [&"neutral", &"sad"]:
				check(highlighted == portrait.texture, "Aneska's neutral and sad poses use their shared authored artwork with speaking brightness")
			else:
				check("Glow" in highlighted.resource_path, "Speaking blends to the actual highlighted artwork")
		else:
			check(is_zero_approx(portrait.highlight_amount), "Non-speaking portraits finish fading to the dimmed base")
			check(not "Glow" in portrait.texture.resource_path, "Non-speaking portraits do not retain a speaking glow")
			check(not portrait.playing, "Listener holds a still pose")
		check(is_equal_approx(portrait.material.get_shader_parameter("highlight_amount"), portrait.highlight_amount), "Rendered blend follows the portrait's transition")


func _settle_dialogue_handoff() -> void:
	if game.dialogue_start_pending:
		game.history.finish_handoffs()
		game._process(game.reveal_delay)


func _settle_portrait_fades() -> void:
	for portrait in [game.aneska, game.yuvan]:
		if portrait.highlight_tween and portrait.highlight_tween.is_valid():
			portrait.highlight_tween.custom_step(1.0)


func _test_portrait_fades() -> void:
	game.restart()
	game.set_process(false)
	var portrait: FrameSequence = game.aneska
	check(portrait.material != game.yuvan.material, "Portraits have independent highlight blends")
	check(is_zero_approx(portrait.highlight_amount), "Speaking starts the fade from the unhighlighted pose")
	portrait.highlight_tween.custom_step(portrait.highlight_fade_in / 2.0)
	check(portrait.highlight_amount > 0.0 and portrait.highlight_amount < 1.0, "Fade-in has a visible intermediate blend")
	portrait.highlight_tween.pause()
	await _snapshot("09-portrait-fade-in", false)
	portrait.highlight_tween.custom_step(portrait.highlight_fade_in)
	check(is_equal_approx(portrait.highlight_amount, 1.0), "Fade-in reaches the highlighted sprite")
	game.finish_typing()
	check(is_equal_approx(portrait.highlight_amount, 1.0), "Finishing a line begins fading without snapping the highlight off")
	portrait.highlight_tween.custom_step(portrait.highlight_fade_out / 2.0)
	var mid_fade: float = portrait.highlight_amount
	check(mid_fade > 0.0 and mid_fade < 1.0, "Fade-out has a visible intermediate blend")
	portrait.highlight_tween.pause()
	await _snapshot("10-portrait-fade-out", false)
	# Reverse a half-finished fade without jumping to either endpoint.
	portrait.on_dialogue_started("Aneska", "happy")
	check(is_equal_approx(portrait.highlight_amount, mid_fade), "A rapid new line preserves the in-progress blend")
	portrait.highlight_tween.custom_step(portrait.highlight_fade_in / 2.0)
	check(portrait.highlight_amount > mid_fade and portrait.highlight_amount < 1.0, "Interrupted fade reverses toward the new speaking state")
	portrait.on_dialogue_completed("Aneska", "happy")
	_settle_portrait_fades()
	_check_portrait_focus("")
	portrait.on_dialogue_started("Aneska", "happy")
	portrait.highlight_tween.custom_step(portrait.highlight_fade_in / 2.0)
	portrait.reset()
	check(is_zero_approx(portrait.highlight_amount) and not portrait.highlight_tween.is_valid(), "Restart clears a pending fade immediately")
	var fade_in := portrait.highlight_fade_in
	var fade_out := portrait.highlight_fade_out
	portrait.highlight_fade_in = 0.0
	portrait.highlight_fade_out = 0.0
	portrait.on_dialogue_started("Aneska", "happy")
	check(is_equal_approx(portrait.highlight_amount, 1.0), "Zero fade-in duration switches immediately")
	portrait.on_dialogue_completed("Aneska", "happy")
	check(is_zero_approx(portrait.highlight_amount), "Zero fade-out duration switches immediately")
	portrait.highlight_fade_in = fade_in
	portrait.highlight_fade_out = fade_out
	game.set_process(true)


func _check_dialogue_layout() -> void:
	check(game.speaker.position.y >= game.dialogue.position.y + game.dialogue.get_content_height() + 12.0, "Speaker attribution is below the full dialogue, including wrapped lines")
	check(game.speaker.position.y + game.speaker.size.y <= game.choices_box.position.y, "Speaker attribution stays above the choices and portraits")


func _test_dialogue_history() -> void:
	game.restart()
	game.set_process(false)
	game.history.set_process(false)
	game.finish_typing()
	check(game.history.get_child_count() == 0, "The readable current line stays in place until the player advances")
	var actual_dialogue: RichTextLabel = game.dialogue
	var completed_line: String = game.dialogue.text
	var original_rect := actual_dialogue.get_global_rect()
	var original_modulate := actual_dialogue.modulate
	game.advance()
	game.choices_box.rows.get_child(0).pressed.emit()
	var memory: RichTextLabel = game.history.get_child(0)
	check(memory == actual_dialogue and game.dialogue != actual_dialogue, "The actual typewriter node becomes the outgoing text")
	check(memory.get_global_rect().is_equal_approx(original_rect) and memory.modulate == original_modulate, "Departure starts at the exact reading position, size, and brightness")
	check(game.dialogue.visible_characters == 0 and game.dialogue_start_pending, "The next line waits for the outgoing text to clear its reading position")
	check(not game.audio.voice.playing, "Typing audio waits with the next line during the handoff")
	check(memory.text == completed_line and memory.mouse_filter == Control.MOUSE_FILTER_IGNORE, "History preserves the completed line and lets clicks through")
	var initial_alpha := memory.modulate.a
	var initial_y := memory.position.y
	var initial_scale := memory.scale.x
	await _snapshot("11-crawl-near")
	game.history._process(game.history.handoff_duration / 2.0)
	game._process(game.history.handoff_duration / 2.0)
	check(memory.position.y < initial_y and memory.scale.x < initial_scale and memory.scale.x > 0.7, "The same text visibly moves and shrinks halfway through departure")
	check(game.dialogue.visible_characters == 0, "The next line does not overlap a departing paragraph")
	await _snapshot("14-dialogue-departure-midpoint")
	game.history._process(game.history.handoff_duration / 2.0)
	game._process(game.history.handoff_duration / 2.0)
	check(not game.dialogue_start_pending and game.audio.voice.playing, "The next line begins speaking once the departure completes")
	game._process(0.13)
	check(game.dialogue.visible_characters >= 2, "Typewriting resumes after the handoff")
	check(memory.position.y < initial_y and memory.scale.x < initial_scale and memory.modulate.a < initial_alpha, "History drifts upward, shrinks, and fades with time")
	check(is_equal_approx(memory.scale.x, memory.scale.y) and is_zero_approx(memory.rotation), "History text stays upright and scales equally in both directions")
	game.finish_typing()
	var older_position := memory.position
	game.advance()
	check(memory.position == older_position, "A new entry does not teleport an older line")
	game.finish_typing()
	game.history._process(0.8)
	game.advance()
	game.finish_typing()
	check(game.history.get_child_count() == 3, "Several completed lines form a receding trail")
	var entries: Array = game.history.entries
	for index in range(1, entries.size()):
		check(entries[index - 1].target_offset >= entries[index].target_offset + entries[index].height, "Rapid advances reserve space for older paragraphs")
		var older: Dictionary = entries[index - 1]
		var newer: Dictionary = entries[index]
		check(older.label.position.y + older.height * older.label.scale.y < newer.label.position.y, "Skipping a handoff keeps the visible history paragraphs separated")
	await _snapshot("12-crawl-trail")
	# Exercise wrapping with a long paragraph from the retained reference script.
	var transcript: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/expected_story.json"))
	var longest := ""
	for line in transcript.main:
		if line.text.length() > longest.length():
			longest = line.text
	game._show_line(longest, ["Yuvan", "angry"])
	game.finish_typing()
	_check_dialogue_layout()
	check(game.dialogue.get_line_count() > 1, "Long dialogue wraps above the attribution")
	if screenshots:
		var window_size := root.size
		root.size = Vector2i(960, 540)
		await process_frame
		await _snapshot("13-long-dialogue-small-window")
		root.size = window_size
		await process_frame
	var long_dialogue: RichTextLabel = game.dialogue
	var long_rect := long_dialogue.get_global_rect()
	var wrapped_lines := long_dialogue.get_line_count()
	game._show_line("A quiet moment.", [])
	check(game.history.get_children().has(long_dialogue) and long_dialogue.get_global_rect().is_equal_approx(long_rect), "Wrapped dialogue also departs from its actual reading position")
	check(long_dialogue.get_line_count() == wrapped_lines, "Moving into history preserves the original line wrapping")
	game.restart()
	check(not game.dialogue_start_pending and game.history.get_child_count() == 0, "Restart during departure cancels the handoff and clears history")
	for index in 20:
		game._show_line(longest, ["Yuvan", "angry"])
		game.finish_typing()
	check(game.history.get_child_count() <= game.history.maximum_entries, "Rapid skipping keeps a bounded number of history labels")
	game.history._process(game.history.handoff_duration + game.history.fade_duration + 0.1)
	check(game.history.get_child_count() == 0, "Faded history is removed completely")
	check(game.dialogue.text == longest, "The current line stays readable after history fades")
	game._show_line("A quiet moment.", [])
	check(game.speaker.text.is_empty(), "Narration does not leave a stale attribution")
	game.restart()
	check(game.history.get_child_count() == 0, "Restart removes the entire crawl")
	game.history.set_process(true)
	game.set_process(true)


func _test_background_recovery() -> void:
	game.restart()
	for background in [game.aneska_background, game.yuvan_background]:
		background.play(&"evening")
		background._process(5.0)
		background.recovery_tween.custom_step(background.recovery_duration / 2.0)
		check(background.recovery_amount > 0.0 and background.recovery_amount < 1.0, "Recovery crossfades rather than snapping from the padded storm canvas")
		background.play(&"twilight")
		check(background.recovery_amount == 0.0 and not background.recovery_tween.is_valid(), "A new storm cancels the old calm crossfade")
		background._process(5.0)
		check(background.texture == background.frames.get_frame_texture(&"twilight", 16), "An interrupted recovery cannot replace the new storm texture")
		background.play(&"evening")
		background._process(5.0)
		background.recovery_tween.custom_step(0.5)
	game.restart()
	for background in [game.aneska_background, game.yuvan_background]:
		check(background.texture == background.frames.get_frame_texture(&"day", 0) and background.recovery_amount == 0.0, "Restart cancels recovery and restores the calm composition immediately")


func _enter_nebula_choices() -> void:
	game.restart()
	game.finish_typing()
	game.story.story.choose_path_string("breaking_point")
	for line in 3:
		game.advance()
		game.finish_typing()
	game.advance()


func _test_nebula_choice_timing() -> void:
	game.set_process(false)
	for background in [game.aneska_background, game.yuvan_background]:
		background.set_process(false)
	_enter_nebula_choices()
	check(game.story.phase == "twilight" and game.story.story.current_choices.size() == 3, "The real nebula beat reaches its three responses")
	check(not game.choices_box.visible and not game.continue_button.visible and not game.hint.visible, "The nebula reveal keeps choices and advance controls out of view")
	var prompt: String = game.dialogue.text
	await _key(KEY_SPACE)
	await _key(KEY_ENTER)
	await _key(KEY_1)
	await _click()
	check(game.dialogue.text == prompt and game.story.aneska_empathy == 0 and game.story.story.current_choices.size() == 3, "Inputs during the reveal cannot choose or skip the pending responses")
	for background in [game.aneska_background, game.yuvan_background]:
		background._process(5.0)
	game.stage_tween.custom_step(game.transition_duration / 2.0)
	game._process(0.0)
	check(not game.choices_box.visible, "Finished nebula frames still wait for the camera movement")
	await _snapshot("28-nebula-unobstructed")
	game.stage_tween.custom_step(game.transition_duration)
	game._process(0.0)
	check(game.choices_box.visible and game.choices_box.rows.get_child_count() == 3, "The pending choices appear automatically when the whole reveal ends")
	await process_frame
	game.choices_box.appearance.custom_step(1.0)
	await _snapshot("29-nebula-choices-after-reveal")
	await _key(KEY_ENTER)
	check("We can slow down" in game.dialogue.text and game.story.aneska_empathy == 1, "The revealed choices still select and score the correct Ink response")
	for step in 12:
		game.finish_typing()
		game.advance()
		if game.choices_box.visible:
			break
	check(game.choices_box.visible and game.choices_box.options[0].text.begins_with("If one of us"), "The later storm choice appears immediately")
	# Check the opposite completion order too, including unequal background timing.
	_enter_nebula_choices()
	game.stage_tween.custom_step(game.transition_duration + 1.0)
	game.aneska_background._process(5.0)
	game._process(0.0)
	check(not game.choices_box.visible, "A finished camera move still waits for both nebula animations")
	game.yuvan_background._process(5.0)
	game._process(0.0)
	check(game.choices_box.visible, "The slower background can release the pending panel")
	_enter_nebula_choices()
	game.restart()
	game._process(game.transition_duration + 1.0)
	check(not game.choices_box.visible and game.pending_choices.is_empty(), "Restart during the reveal cancels the old choices")
	game.finish_typing()
	game.advance()
	check(game.choices_box.visible and game.story.phase == "day", "Opening choices retain their immediate timing after restart")
	game.restart()
	game.set_process(true)
	for background in [game.aneska_background, game.yuvan_background]:
		background.set_process(true)


func _test_ending_reveal() -> void:
	for result in [[-1, "A Quiet Distance", "25-ending-distance"], [2, "Still Reaching", "26-ending-reaching"]]:
		game.restart()
		game.finish_typing()
		game.story.story.variables_state.set_variable("aneska_empathy", result[0])
		game.story.story.choose_path_string("resolve_conversation")
		for step in 30:
			if game.story.ended:
				break
			game.advance()
			game.finish_typing()
		check(game.story.ended and game.ending_title.text == result[1], "Each resolution receives its own prominent ending title")
		game.stage_tween.custom_step(11.0)
		for background in [game.aneska_background, game.yuvan_background]:
			background._process(5.0)
			background.recovery_tween.custom_step(1.1)
		game.ending_tween.custom_step(2.0)
		check(game.dialogue.modulate.a == 0.0 and game.speaker.modulate.a == 0.0, "The completed dialogue yields visual focus to the ending")
		check(game.ending_title.get_theme_font_size("font_size") > game.dialogue.get_theme_font_size("normal_font_size"), "The ending title is larger than conversation text")
		check(game.replay_button.has_focus(), "The completed reveal makes replay keyboard accessible")
		await _snapshot(result[2])
		if screenshots and result[0] == -1:
			var window_size := root.size
			root.size = Vector2i(960, 540)
			await process_frame
			await _snapshot("27-ending-small-window")
			root.size = window_size
			await process_frame
		await _key(KEY_ENTER)
		check(not game.ending.visible and game.typing and game.story.phase == "day", "Enter on Read again starts a fresh playthrough")
	# Restart halfway through a reveal must not let the old tween hide new text.
	game.finish_typing()
	game._finish_story()
	game.ending_tween.custom_step(0.5)
	var interrupted: Tween = game.ending_tween
	game.restart()
	check(not interrupted.is_valid() and not game.ending.visible and game.dialogue.modulate.a == 1.0, "Restart cancels an unfinished ending reveal")


func _test_frames() -> void:
	for character in ["aneska", "yuvan"]:
		var frames: SpriteFrames = load("res://data/%s_portrait.tres" % character)
		for animation in frames.get_animation_names():
			for index in frames.get_frame_count(animation):
				check(frames.get_frame_texture(animation, index) != null, "All portrait frames resolve")
		var background: SpriteFrames = load("res://data/%s_background.tres" % character)
		check(background.get_frame_count("twilight") == 17, "All storm frames migrate")
		for index in 17:
			check(background.get_frame_texture("twilight", index) == background.get_frame_texture("evening", 16 - index), "Evening preserves reversed Unity frame order")


func _click(position: Vector2 = Vector2(600, 330)) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = root.get_final_transform() * position
	Input.parse_input_event(event)
	await process_frame
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame


func _snapshot(filename: String, settle_portraits: bool = true) -> void:
	if not screenshots:
		return
	if settle_portraits:
		_settle_portrait_fades()
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var error := root.get_texture().get_image().save_png("res://test-results/%s.png" % filename)
	check(error == OK, "Saved rendered snapshot " + filename)
