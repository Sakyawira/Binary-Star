@tool
class_name FrameSequence
extends TextureRect
## A SpriteFrames player that fits differently sized source images to a UI rect.

@export var frames: SpriteFrames
@export var initial_animation: StringName = &"neutral_idle"
@export var character_name := ""
@export_range(0.0, 1.0, 0.01) var highlight_fade_in := 0.15
@export_range(0.0, 1.0, 0.01) var highlight_fade_out := 0.25

var animation: StringName
var frame_index := 0
var playing := false
var elapsed := 0.0
var highlight_tween: Tween
var _portrait_material: ShaderMaterial
var highlight_amount := 0.0:
	set(value):
		highlight_amount = value
		if _portrait_material:
			_portrait_material.set_shader_parameter("highlight_amount", value)


func _ready() -> void:
	if not character_name.is_empty():
		# Each portrait needs its own blend amount and highlighted texture.
		_portrait_material = ShaderMaterial.new()
		_portrait_material.shader = preload("res://shaders/portrait_highlight.gdshader")
		material = _portrait_material
	reset()
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
	if not character_name.is_empty():
		_set_portrait_pose(String(initial_animation).trim_suffix("_idle"))
		_fade_highlight(0.0, 0.0)


func on_dialogue_started(character: String, emotion: String) -> void:
	if character == character_name:
		_set_portrait_pose(emotion)
		_fade_highlight(1.0, highlight_fade_in)
	else:
		_fade_highlight(0.0, highlight_fade_out)


func _set_portrait_pose(emotion: String) -> void:
	var pose := emotion if frames.has_animation(emotion) else "neutral"
	play(pose)
	playing = false
	# Keep the base texture fixed while blending to the authored *_idle glow sprite.
	var highlighted := pose + "_idle"
	_portrait_material.set_shader_parameter("highlighted_texture", frames.get_frame_texture(highlighted, 0))


func _fade_highlight(target: float, duration: float) -> void:
	if highlight_tween and highlight_tween.is_valid():
		highlight_tween.kill()
	if duration <= 0.0 or Engine.is_editor_hint() or is_equal_approx(highlight_amount, target):
		highlight_amount = target
		return
	# A new turn continues from the current blend, including mid-fade reversals.
	highlight_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(self, "highlight_amount", target, duration)


func on_dialogue_completed(_character: String, _emotion: String) -> void:
	_fade_highlight(0.0, highlight_fade_out)
