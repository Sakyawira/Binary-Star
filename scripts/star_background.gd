@tool
extends FrameSequence
## The storm canvases have different padding and orientation from the calm art.
## Finish recovery on the original calm texture instead of holding storm frame 1.

@export var recovery_duration := 1.0

var recovery_tween: Tween
var _recovery_material: ShaderMaterial
var recovery_amount := 0.0:
	set(value):
		recovery_amount = value
		if _recovery_material:
			_recovery_material.set_shader_parameter("recovery_amount", value)


func _ready() -> void:
	_recovery_material = ShaderMaterial.new()
	_recovery_material.shader = preload("res://shaders/background_recovery.gdshader")
	_recovery_material.set_shader_parameter("calm_texture", frames.get_frame_texture(&"day", 0))
	material = _recovery_material
	super._ready()


func _process(delta: float) -> void:
	var was_playing := playing
	super._process(delta)
	if was_playing and not playing and animation == &"evening":
		recovery_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		recovery_tween.tween_property(self, "recovery_amount", 1.0, recovery_duration)
		recovery_tween.tween_callback(_hold_calm)


func play(next_animation: StringName) -> void:
	if recovery_tween and recovery_tween.is_valid():
		recovery_tween.kill()
	recovery_amount = 0.0
	super.play(next_animation)


func _hold_calm() -> void:
	texture = frames.get_frame_texture(&"day", 0)
	recovery_amount = 0.0
