extends SceneTree
## Opens the real distant ending for visual review; Read again plays normally.


func _initialize() -> void:
	call_deferred("_preview")


func _preview() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.finish_typing()
	game.story.story.variables_state.set_variable("aneska_empathy", -1)
	game.story.story.choose_path_string("resolve_conversation")
	for step in 30:
		if game.story.ended:
			break
		game.advance()
		game.finish_typing()
	game.stage_tween.custom_step(11.0)
	for background in [game.aneska_background, game.yuvan_background]:
		background._process(5.0)
		background.recovery_tween.custom_step(1.1)
