extends SceneTree
## Run with --script tests/preview_choices.gd to jump to the live opening choices.

var game: Control


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.title = "Binary Star — Yuvan"
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.finish_typing()
	game.advance()
