shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;

uniform sampler2D highlighted_texture : source_color, filter_linear, repeat_disable;
uniform float highlight_amount : hint_range(0.0, 1.0) = 0.0;
varying vec4 canvas_tint;

void vertex() {
	canvas_tint = COLOR;
}

void fragment() {
	vec4 resting = texture(TEXTURE, UV);
	vec4 highlighted = texture(highlighted_texture, UV);
	// Mix premultiplied colors so transparent outlines crossfade without dark edges.
	resting.rgb *= resting.a * 0.55;
	highlighted.rgb *= highlighted.a;
	vec4 blended = mix(resting, highlighted, highlight_amount);
	COLOR = vec4(blended.rgb * canvas_tint.rgb * canvas_tint.a, blended.a * canvas_tint.a);
}
