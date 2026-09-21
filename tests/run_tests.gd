extends SceneTree
## Integration checks against the real scene and serialized signal graph.
## Run: godot --headless --path . --script tests/run_tests.gd
## Render snapshots: godot --path . --script tests/run_tests.gd -- --screenshots

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
	create_timer(60.0).timeout.connect(func():
		printerr("FAIL: Test suite timed out")
		quit(1)
	)
	game = load("res://scenes/main.tscn").instantiate()
	game.get_node("Story").line_ready.connect(func(text, tags): lines.append({"text": text, "tags": tags}))
	game.get_node("Story").phase_changed.connect(func(phase): phases.append(phase))
	game.get_node("Story").failed.connect(func(message): check(false, "Ink error: " + message))
	root.add_child(game)
	await process_frame
	check(lines.size() == 1, "First line starts on scene load")
	check(game.dialogue.text == "“I do - you are”", "Original opening text is preserved")
	check(game.typing, "Typewriter starts")
	check(game.aneska.animation == &"happy", "Speaker tag starts the correct animation")
	check(game.audio.voice.playing, "Dialogue-start signal starts typing audio")
	check(game.audio.current_act == 0, "Day signal starts act one")
	game._process(0.13)
	check(game.dialogue.visible_characters >= 2, "Text reveals at the original 65ms cadence")
	await _click()
	check(not game.typing and lines.size() == 1, "Click reveals the current line without skipping it")
	check(game.aneska.animation == &"happy_idle", "Dialogue-completed signal selects the resting portrait")
	check(not game.audio.voice.playing, "Dialogue-completed signal stops typing audio")
	await _snapshot("01-calm")
	await _key(KEY_SPACE)
	check(lines.size() == 2 and game.active_speaker == "Yuvan", "Keyboard advances once to Yuvan")
	game.finish_typing()
	await _snapshot("02-long-dialogue")
	game.continue_button.pressed.emit()
	check(phases == ["day", "twilight"], "Ink storm callback fires exactly at the third line")
	check(game.audio.current_act == 1, "Storm signal starts act two")
	game.stage_tween.custom_step(11.0)
	game.aneska_background._process(5.0)
	game.yuvan_background._process(5.0)
	check(game.aneska.size.is_equal_approx(Vector2(231.5, 271)), "Storm signal zooms portraits out")
	check(game.aneska_background.frame_index == 16 and not game.aneska_background.playing, "Storm holds its last frame")
	game.audio.fade.custom_step(2.0)
	check(is_equal_approx(game.audio.players[1].volume_linear, 0.195), "Crossfade reaches original volume")
	check(not game.audio.players[0].playing, "Crossfade stops the previous act")
	game.finish_typing()
	await _snapshot("03-storm")
	game.advance()
	game.finish_typing()
	game.advance()
	check(phases == ["day", "twilight", "evening"], "Ink ends the storm at the fifth line")
	check(game.audio.current_act == 2, "End-storm signal starts act three")
	game.stage_tween.custom_step(11.0)
	game.aneska_background._process(5.0)
	check(game.aneska.size.is_equal_approx(Vector2(463, 542)), "End-storm restores portrait size")
	game.yuvan_background._process(5.0)
	check(game.aneska_background.frame_index == 16, "Reverse storm animation completes")
	game.finish_typing()
	await _snapshot("04-after-storm")
	for i in 60:
		if game.story.ended:
			break
		game.finish_typing()
		game.advance()
	check(game.story.ended, "Story reaches END")
	check(lines.size() == 26, "All 26 active dialogue lines run")
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/expected_story.json"))
	# Ink collapses runs of spaces/tabs in output (the source has a double space
	# on line 10). Keep the source-derived fixture literal and normalize here.
	var whitespace := RegEx.create_from_string("[ \\t]+")
	for route in expected.values():
		for line in route:
			line.text = whitespace.sub(line.text, " ", true)
	check(lines == expected.main, "Every active line and tag matches the original Ink source transcript")
	for index in mini(lines.size(), expected.main.size()):
		if lines[index] != expected.main[index]:
			printerr("Transcript difference at line %d: expected %s, got %s" % [index + 1, expected.main[index], lines[index]])
	check(lines[-1].text == '"Good night. I love you too..."', "Original final line is preserved")
	check(game.replay_button.visible, "Story-finished signal shows replay")
	check(not game.continue_button.visible, "Story-finished signal hides continue")
	for line in lines:
		check(line.tags.size() == 2 and line.tags[0] in ["Aneska", "Yuvan"], "Speaker and emotion tags survive Ink")
	await _snapshot("05-ending")
	await _key(KEY_M)
	check(game.audio.muted and AudioServer.is_bus_mute(0), "Mute input reaches audio through signals")
	await _key(KEY_M)
	check(not game.audio.muted, "Audio can be unmuted")
	game.replay_button.pressed.emit()
	check(game.typing and game.story.phase == "day" and game.audio.current_act == 0, "Replay resets story, stage and audio")
	check(game.dialogue.text == "“I do - you are”", "Replay returns to the original first line")
	game.get_node("Toolbar/Restart").pressed.emit()
	game.finish_typing()
	check(game.previous.text.is_empty(), "Restart during typing clears dialogue history")
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
	for count in [1, 2, 4]:
		await _test_choices(count)
	_test_frames()
	if screenshots:
		game.restart()
		game.finish_typing()
		root.size = Vector2i(960, 540)
		await process_frame
		await _snapshot("06-small-window")
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	if failures.is_empty():
		print("PASS: %d checks — story, branches, choices, signals, sprites, audio, restart and input." % checks)
	else:
		printerr("FAILED: %d of %d checks" % [failures.size(), checks])
	quit(0 if failures.is_empty() else 1)


func _test_choices(count: int) -> void:
	# Minimal Ink JSON equivalent to: * [Option N] -> a line, then END.
	var content: Array = []
	var branches := {}
	for i in count:
		content.append_array(["ev", "str", "^Option %d" % i, "/str", "/ev", {"*": "0.c-%d" % i, "flg": 20}])
		branches["c-%d" % i] = ["\n", "^Selected %d" % i, "\n", "end", {"#f": 5}]
	content.append(branches)
	var fixture := JSON.stringify({"inkVersion": 21, "root": [content, "done", null], "listDefs": {}})
	game.story.start(fixture)
	game.story.advance()
	check(game.choices_box.visible and game.choices_box.get_child_count() == count, "%d choices render from the choices-ready signal" % count)
	game.story.choose(-1)
	check(game.story.story.current_choices.size() == count, "Invalid choice is safely ignored")
	game.choices_box.get_child(count - 1).pressed.emit()
	check(game.dialogue.text == "Selected %d" % (count - 1), "Choice-button signal chooses the corresponding Ink branch")
	check(not game.choices_box.visible, "Choosing hides the choice UI")
	game.finish_typing()
	game.advance()
	check(game.story.ended, "Choice branch reaches END")
	await process_frame


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


func _click() -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = Vector2(600, 330)
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


func _snapshot(filename: String) -> void:
	if not screenshots:
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var error := root.get_texture().get_image().save_png("res://test-results/%s.png" % filename)
	check(error == OK, "Saved rendered snapshot " + filename)
