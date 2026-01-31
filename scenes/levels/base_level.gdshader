shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 0.2, 0.2, 0.35);
uniform float vignette_strength = 0.35;

void fragment() {
	vec2 uv = SCREEN_UV;
	float d = distance(uv, vec2(0.5));
	float vignette = smoothstep(0.55, 0.95, d) * vignette_strength;
	vec4 c = tint_color;
	c.a = clamp(c.a + vignette, 0.0, 1.0);
	COLOR = c;
}
