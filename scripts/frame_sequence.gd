@tool
class_name FrameSequence
extends TextureRect
## A SpriteFrames player that fits differently sized source images to a UI rect.

@export var frames: SpriteFrames
@export var initial_animation: StringName = &"neutral_idle"
@export var character_name := ""

var animation: StringName
var frame_index := 0
var playing := false
var elapsed := 0.0


func _ready() -> void:
	play(initial_animation)
	if Engine.is_editor_hint():
		playing = false


func _process(delta: float) -> void:
	if not playing or Engine.is_editor_hint():
		return
	elapsed += delta
	var duration := 1.0 / frames.get_animation_speed(animation)
	while elapsed >= duration and playing:
		elapsed -= duration
		frame_index += 1
		if frame_index >= frames.get_frame_count(animation):
			if frames.get_animation_loop(animation):
				frame_index = 0
			else:
				frame_index = frames.get_frame_count(animation) - 1
				playing = false
		texture = frames.get_frame_texture(animation, frame_index)


func play(next_animation: StringName) -> void:
	if frames == null or not frames.has_animation(next_animation):
		push_error("Missing sprite animation: %s" % next_animation)
		return
	animation = next_animation
	frame_index = 0
	elapsed = 0.0
	texture = frames.get_frame_texture(animation, 0)
	playing = frames.get_frame_count(animation) > 1


func reset() -> void:
	play(initial_animation)


func on_dialogue_started(character: String, emotion: String) -> void:
	if character == character_name:
		play(emotion if frames.has_animation(emotion) else "neutral")


func on_dialogue_completed(character: String, emotion: String) -> void:
	if character == character_name:
		var idle := emotion + "_idle"
		play(idle if frames.has_animation(idle) else "neutral_idle")
