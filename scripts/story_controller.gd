class_name StoryController
extends Node
## Keeps Ink flow separate from the view so every story path can be tested.

signal line_ready(text: String, tags: Array)
signal choices_ready(choices: Array)
signal finished
signal phase_changed(phase: String)
signal failed(message: String)

const STORY_PATH := "res://Assets/Ink/BinaryStar.json"
var story: InkStory
var phase := "day"
var ended := false
var elapsed_since_continue := 0.0


func _process(delta: float) -> void:
	elapsed_since_continue += delta


func start(json_text: String = "") -> void:
	if json_text.is_empty():
		json_text = FileAccess.get_file_as_string(STORY_PATH).trim_prefix("\ufeff")
	if not JSON.parse_string(json_text) is Dictionary:
		failed.emit("The compiled Ink story could not be read.")
		return
	story = InkStory.new(json_text)
	story.on_error.connect(_on_story_error)
	story.bind_external_function("InitiateStorm", self, "initiate_storm")
	story.bind_external_function("EndStorm", self, "end_storm")
	story.bind_external_function("ChangeBackground", self, "change_background")
	ended = false
	elapsed_since_continue = 0.0
	phase = "day"
	phase_changed.emit(phase)


func advance() -> void:
	if story == null or ended:
		return
	# Preserve the Unity project's 1000-second threshold and Ink variable.
	# Its branch selector is currently commented out in the source story.
	if story.variables_state.get_variable("conversation_speed") != null:
		if elapsed_since_continue < 1000.0:
			var speed: int = story.variables_state.get_variable("conversation_speed")
			story.variables_state.set_variable("conversation_speed", speed + 1)
	elapsed_since_continue = 0.0
	while story.can_continue:
		var text := story.continue_story().strip_edges()
		if not text.is_empty():
			line_ready.emit(text, story.current_tags)
			return
	if not story.current_choices.is_empty():
		var choices: Array = []
		for choice in story.current_choices:
			choices.append({"index": choice.index, "text": choice.text.strip_edges()})
		choices_ready.emit(choices)
	else:
		ended = true
		finished.emit()


func choose(index: int) -> void:
	if story == null or index < 0 or index >= story.current_choices.size():
		return
	story.choose_choice_index(index)
	advance()


func initiate_storm() -> void:
	phase = "twilight"
	phase_changed.emit(phase)


func end_storm() -> void:
	phase = "evening"
	phase_changed.emit(phase)


func change_background(place: String, time: String) -> String:
	if place == "Planet" and time.to_lower() in ["day", "twilight", "evening"]:
		phase = time.to_lower()
		phase_changed.emit(phase)
	return ""


func _on_story_error(message: String, _type: int) -> void:
	failed.emit(message)
