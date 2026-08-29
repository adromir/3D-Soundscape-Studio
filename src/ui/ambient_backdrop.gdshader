shader_type canvas_item;

// Ambient Organic Harmonic Shader with Real Zen Textures
// Author: Adromir

uniform sampler2D bg_texture : source_color, filter_linear_mipmap;
uniform bool use_texture = true;
uniform vec4 bg_color : source_color = vec4(0.045, 0.052, 0.065, 1.0);
uniform vec4 orb1_color : source_color = vec4(0.96, 0.82, 0.48, 0.35); // Luminous Golden Amber Wave
uniform vec4 orb2_color : source_color = vec4(0.18, 0.80, 0.60, 0.28); // Bioluminescent Jade / Moss Mist
uniform vec4 orb3_color : source_color = vec4(0.80, 0.58, 0.35, 0.22); // Warm Honey Bamboo Glow

void fragment() {
	vec2 uv = UV;
	float time = TIME * 0.20;
	
	// Base textured backdrop or solid color
	vec3 color = bg_color.rgb;
	if (use_texture) {
		vec4 tex = texture(bg_texture, uv);
		color = mix(color, tex.rgb, 0.70);
	}
	
	// Moving atmospheric orbs
	vec2 p1 = vec2(0.30 + 0.25 * cos(time * 0.7), 0.30 + 0.20 * sin(time * 0.5));
	float d1 = length(uv - p1);
	float g1 = smoothstep(0.75, 0.0, d1);
	
	vec2 p2 = vec2(0.70 + 0.20 * sin(time * 0.6), 0.65 + 0.25 * cos(time * 0.4));
	float d2 = length(uv - p2);
	float g2 = smoothstep(0.75, 0.0, d2);
	
	vec2 p3 = vec2(0.50 + 0.30 * cos(time * 0.4 + 1.5), 0.85 + 0.15 * sin(time * 0.8));
	float d3 = length(uv - p3);
	float g3 = smoothstep(0.60, 0.0, d3);
	
	// Organic flowing harmonic acoustic wave ribbons (Zen icon ribbon effect)
	float wave1 = sin(uv.x * 6.28 + time * 0.8 + sin(uv.y * 4.0)) * 0.08;
	float wave2 = cos(uv.x * 9.42 - time * 0.6 + cos(uv.y * 6.0)) * 0.05;
	float ribbon1 = smoothstep(0.04, 0.0, abs(uv.y - 0.52 - wave1));
	float ribbon2 = smoothstep(0.03, 0.0, abs(uv.y - 0.56 - wave2));
	
	// Composite background
	color = mix(color, orb1_color.rgb, g1 * orb1_color.a);
	color = mix(color, orb2_color.rgb, g2 * orb2_color.a);
	color = mix(color, orb3_color.rgb, g3 * orb3_color.a);
	
	// Blend subtle golden harmonic ribbons
	color += orb1_color.rgb * (ribbon1 * 0.20 + ribbon2 * 0.14);
	
	// Soft vignette for focus
	float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
	vignette = clamp(pow(16.0 * vignette, 0.25), 0.0, 1.0);
	color *= (0.75 + 0.25 * vignette);
	
	COLOR = vec4(color, 1.0);
}
