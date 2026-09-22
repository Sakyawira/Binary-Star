shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec2 distance_from_title = (UV - vec2(0.5, 0.46)) * vec2(1.7, 1.0);
	float glow = exp(-dot(distance_from_title, distance_from_title) * 18.0);
	vec3 tint = mix(vec3(0.008, 0.018, 0.055), vec3(0.23, 0.20, 0.40), glow);
	COLOR = vec4(tint, mix(0.48, 0.40, glow)) * COLOR;
}
