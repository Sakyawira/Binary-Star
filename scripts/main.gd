extends Control

signal continue_requested
signal choice_selected(index: int)
signal restart_requested
signal dialogue_started(character: String, emotion: String)
signal dialogue_completed(character: String, emotion: String)
signal sound_toggled(muted: bool)

const CHARACTER_SIZE := Vector2(463, 542)
const BACKGROUND_SIZE := Vector2(910, 910)

@export var seconds_per_character := 0.065
@export var transition_duration := 10.0

@onready var story: StoryController = $Story
@onready var audio: NovelAudio = $Audio
@onready var aneska: FrameSequence = $Aneska
@onready var yuvan: FrameSequence = $Yuvan
@onready var aneska_background: FrameSequence = $AneskaBackground
@onready var yuvan_background: FrameSequence = $YuvanBackground
@onready var dialogue: RichTextLabel = $Dialogue
@onready var previous: Label = $PreviousDialogue
@onready var speaker: Label = $Speaker
@onready var hint: Label = $Hint
@onready var choices_box: VBoxContainer = $Choices
@onready var continue_button: Button = $Continue
@onready var replay_button: Button = $Replay
@onready var mute_button: Button = $Toolbar/Mute

var typing := false
var typing_elapsed := 0.0
var active_speaker := ""
var active_emotion := "neutral"
var stage_tween: Tween
var history_tween: Tween


func _ready() -> void:
	# The event graph is serialized as Godot signal connections in main.tscn.
	restart()


func _process(delta: float) -> void:
	if not typing:
		return
	typing_elapsed += delta
	dialogue.visible_characters = int(typing_elapsed / maxf(seconds_per_character, 0.001))
	if dialogue.visible_characters >= dialogue.get_total_character_count():
		finish_typing()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
			advance()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_M:
			mute_button.button_pressed = not mute_button.button_pressed
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		advance()
		get_viewport().set_input_as_handled()


func advance() -> void:
	if typing:
		finish_typing()
	elif not choices_box.visible and not story.ended:
		continue_requested.emit()


func restart() -> void:
	typing = false
	typing_elapsed = 0.0
	active_speaker = ""
	active_emotion = "neutral"
	dialogue.text = ""
	previous.text = ""
	_clear_choices()
	replay_button.hide()
	continue_button.show()
	restart_requested.emit()
	continue_requested.emit()


func _show_line(text: String, tags: Array) -> void:
	if history_tween and history_tween.is_valid():
		history_tween.kill()
	previous.text = dialogue.text
	previous.position.y = 100.0
	previous.modulate.a = 0.85
	history_tween = create_tween().set_parallel(true)
	history_tween.tween_property(previous, "position:y", 65.0, 0.5)
	history_tween.tween_property(previous, "modulate:a", 0.4, 0.5)
	dialogue.text = text
	dialogue.visible_characters = 0
	typing_elapsed = 0.0
	typing = true
	active_speaker = str(tags[0]) if not tags.is_empty() else ""
	active_emotion = str(tags[1]).to_lower() if tags.size() > 1 else "neutral"
	speaker.text = active_speaker.to_upper()
	speaker.modulate = Color("e9b9df") if active_speaker == "Aneska" else Color("b7d9f4")
	dialogue_started.emit(active_speaker, active_emotion)
	hint.text = "Click or press Space to reveal the line"
	continue_button.text = "Reveal  ›"


func finish_typing() -> void:
	if not typing:
		return
	typing = false
	dialogue.visible_characters = -1
	dialogue_completed.emit(active_speaker, active_emotion)
	hint.text = "Click or press Space to continue"
	continue_button.text = "Continue  ›"


func _change_phase(phase: String) -> void:
	if stage_tween and stage_tween.is_valid():
		stage_tween.kill()
	var storm := phase == "twilight"
	var portrait_size := CHARACTER_SIZE * (0.5 if storm else 1.0)
	var background_size := Vector2(975, 975) if storm else BACKGROUND_SIZE
	var margin := 81.0 if storm else 130.0
	var bottom := 39.0 if storm else 0.0
	var duration := 0.0 if phase == "day" else transition_duration
	if duration > 0.0:
		stage_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Unity's camera moves from z=-13 to z=-29 at a 40-degree field of view.
	# The 38.4 x 21.6 starfield is projected into the same 1920 x 1080 canvas.
	var camera_distance := 29.0 if storm else 13.0
	var starfield_scale := 21.6 / (2.0 * camera_distance * tan(deg_to_rad(20.0)))
	var starfield_size := Vector2(1920, 1080) * starfield_scale
	_resize_on_stage($Starfield, starfield_size, (Vector2(1920, 1080) - starfield_size) / 2.0, duration)
	_resize_on_stage(aneska, portrait_size, Vector2(260, 1067 - portrait_size.y), duration)
	_resize_on_stage(yuvan, portrait_size, Vector2(1660 - portrait_size.x, 1067 - portrait_size.y), duration)
	_resize_on_stage(aneska_background, background_size, Vector2(margin, 1080 - bottom - background_size.y), duration)
	_resize_on_stage(yuvan_background, background_size, Vector2(1920 - margin - background_size.x, 1080 - bottom - background_size.y), duration)


func _resize_on_stage(node: Control, target_size: Vector2, target_position: Vector2, duration: float) -> void:
	if duration == 0.0:
		node.size = target_size
		node.position = target_position
	else:
		stage_tween.tween_property(node, "size", target_size, duration)
		stage_tween.tween_property(node, "position", target_position, duration)


func _show_choices(choices: Array) -> void:
	_clear_choices()
	choices_box.show()
	continue_button.hide()
	hint.text = "Choose a response"
	for choice in choices:
		var button := Button.new()
		button.text = choice.text
		button.custom_minimum_size.y = 64
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(_choose.bind(int(choice.index)))
		choices_box.add_child(button)
	if choices_box.get_child_count() > 0:
		choices_box.get_child(0).grab_focus()


func _choose(index: int) -> void:
	_clear_choices()
	continue_button.show()
	choice_selected.emit(index)


func _clear_choices() -> void:
	for child in choices_box.get_children():
		choices_box.remove_child(child)
		child.queue_free()
	choices_box.hide()


func _finish_story() -> void:
	continue_button.hide()
	hint.text = "End of conversation"
	replay_button.show()


func _toggle_audio(value: bool) -> void:
	sound_toggled.emit(value)
	mute_button.text = "Sound off" if value else "Sound on"


func _show_error(message: String) -> void:
	typing = false
	dialogue_completed.emit(active_speaker, active_emotion)
	dialogue.text = "The story could not continue.\n" + message
	dialogue.visible_characters = -1
	continue_button.hide()
	replay_button.show()
	push_error(message)
