shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;

uniform sampler2D calm_texture : source_color, filter_linear, repeat_disable;
uniform float recovery_amount : hint_range(0.0, 1.0) = 0.0;
varying vec4 canvas_tint;

void vertex() {
	canvas_tint = COLOR;
}

void fragment() {
	vec4 storm = texture(TEXTURE, UV);
	vec4 calm = texture(calm_texture, UV);
	storm.rgb *= storm.a;
	calm.rgb *= calm.a;
	vec4 blended = mix(storm, calm, recovery_amount);
	COLOR = vec4(blended.rgb * canvas_tint.rgb * canvas_tint.a, blended.a * canvas_tint.a);
}
