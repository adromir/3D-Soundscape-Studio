shader_type canvas_item;

// Author: Adromir
// Repository: https://github.com/adromir/3D-Soundscape-Studio

uniform bool u_enabled = true;
uniform float u_opacity : hint_range(0.0, 1.0) = 0.65;
uniform int u_colormap : hint_range(0, 3) = 0; // 0: Thermal, 1: Phosphor, 2: Cyberpunk
uniform vec2 u_center_px;
uniform float u_radius_px;
uniform float u_soundspace_scale = 10.0;
uniform float u_ambient_floor = 0.0;
uniform vec2 u_resolution = vec2(800.0, 600.0);

const int MAX_SOURCES = 32;
uniform int u_source_count = 0;
uniform vec2 u_sources_px[MAX_SOURCES];
uniform float u_volumes[MAX_SOURCES];
uniform float u_pulses[MAX_SOURCES];

vec3 colormap_thermal(float t) {
	t = clamp(t, 0.0, 1.0);
	vec3 c = vec3(0.0);
	if (t < 0.25) {
		float f = t / 0.25;
		c = mix(vec3(0.02, 0.08, 0.25), vec3(0.0, 0.65, 0.95), f);
	} else if (t < 0.5) {
		float f = (t - 0.25) / 0.25;
		c = mix(vec3(0.0, 0.65, 0.95), vec3(0.15, 0.90, 0.40), f);
	} else if (t < 0.75) {
		float f = (t - 0.5) / 0.25;
		c = mix(vec3(0.15, 0.90, 0.40), vec3(1.0, 0.85, 0.10), f);
	} else {
		float f = (t - 0.75) / 0.25;
		c = mix(vec3(1.0, 0.85, 0.10), vec3(1.0, 0.18, 0.12), f);
	}
	return c;
}

vec3 colormap_phosphor(float t) {
	t = clamp(t, 0.0, 1.0);
	return mix(vec3(0.01, 0.18, 0.08), mix(vec3(0.15, 0.95, 0.35), vec3(0.10, 0.98, 0.92), t), t);
}

vec3 colormap_cyberpunk(float t) {
	t = clamp(t, 0.0, 1.0);
	return mix(vec3(0.12, 0.02, 0.28), mix(vec3(0.95, 0.10, 0.75), vec3(0.05, 0.95, 1.0), t), t);
}

void fragment() {
	vec2 pixel_pos = UV * u_resolution;
	float dist_from_center = distance(pixel_pos, u_center_px);

	if (u_enabled && dist_from_center <= u_radius_px) {
		float total_spl = u_ambient_floor;

		for (int i = 0; i < MAX_SOURCES; i++) {
			if (i < u_source_count) {
				float d_px = distance(pixel_pos, u_sources_px[i]);
				float d_meters = (d_px / max(u_radius_px, 0.001)) * u_soundspace_scale;
				float vol = u_volumes[i] * u_pulses[i];
				float atten = 1.0 / (1.0 + d_meters * 0.65 + d_meters * d_meters * 0.06);
				total_spl += vol * atten;
			}
		}

		float normalized_intensity = clamp(total_spl * 0.85, 0.0, 1.0);

		// Iso-dB contour highlight lines
		float contour = 0.0;
		float contour_step = fract(normalized_intensity * 7.0);
		if (contour_step > 0.86 && normalized_intensity > 0.06) {
			contour = 0.22;
		}

		vec3 col = vec3(0.0);
		if (u_colormap == 0) {
			col = colormap_thermal(normalized_intensity);
		} else if (u_colormap == 1) {
			col = colormap_phosphor(normalized_intensity);
		} else {
			col = colormap_cyberpunk(normalized_intensity);
		}

		col += vec3(contour);

		float rim_feather = smoothstep(u_radius_px, u_radius_px - 8.0, dist_from_center);
		float alpha = smoothstep(0.02, 0.22, normalized_intensity) * u_opacity * rim_feather;

		COLOR = vec4(col, alpha);
	} else {
		COLOR = vec4(0.0);
	}
}
