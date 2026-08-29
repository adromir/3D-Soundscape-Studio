shader_type canvas_item;

// Ambient Liquid Caustic Shader for authentic Glassmorphism backdrop
// Author: Adromir

uniform vec4 bg_color : source_color = vec4(0.04, 0.055, 0.09, 1.0);
uniform vec4 orb1_color : source_color = vec4(0.0, 0.55, 0.95, 0.35); // Cyan/Teal Caustic
uniform vec4 orb2_color : source_color = vec4(0.45, 0.15, 0.85, 0.28); // Deep Violet Caustic
uniform vec4 orb3_color : source_color = vec4(0.0, 0.85, 0.80, 0.22); // Aquamarine Caustic

void fragment() {
	vec2 uv = UV;
	float time = TIME * 0.25;
	
	// Moving orb 1 (Cyan)
	vec2 p1 = vec2(0.25 + 0.20 * cos(time * 0.8), 0.35 + 0.25 * sin(time * 0.6));
	float d1 = length(uv - p1);
	float g1 = smoothstep(0.65, 0.0, d1);
	
	// Moving orb 2 (Violet)
	vec2 p2 = vec2(0.75 + 0.18 * sin(time * 0.7), 0.65 + 0.22 * cos(time * 0.5));
	float d2 = length(uv - p2);
	float g2 = smoothstep(0.70, 0.0, d2);
	
	// Moving orb 3 (Aquamarine center-bottom)
	vec2 p3 = vec2(0.50 + 0.25 * cos(time * 0.5 + 2.0), 0.80 + 0.15 * sin(time * 0.9));
	float d3 = length(uv - p3);
	float g3 = smoothstep(0.55, 0.0, d3);
	
	// Composite background with glowing liquid orbs
	vec3 color = bg_color.rgb;
	color = mix(color, orb1_color.rgb, g1 * orb1_color.a);
	color = mix(color, orb2_color.rgb, g2 * orb2_color.a);
	color = mix(color, orb3_color.rgb, g3 * orb3_color.a);
	
	// Subtle vignette
	float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
	vignette = clamp(pow(16.0 * vignette, 0.25), 0.0, 1.0);
	color *= (0.7 + 0.3 * vignette);
	
	COLOR = vec4(color, 1.0);
}
