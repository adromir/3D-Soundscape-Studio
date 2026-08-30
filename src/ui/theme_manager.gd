class_name ThemeManager
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir

enum ThemeMode {
	ZEN,
	DARK,
	LIGHT,
	CYBERPUNK,
	FANTASY,
	SCIFI,
	HISTORIC,
	JUNGLE,
	OCEAN
}

static var current_theme: ThemeMode = ThemeMode.ZEN

const THEME_NAMES: Dictionary = {
	ThemeMode.ZEN: "Organic Zen",
	ThemeMode.DARK: "Aetheric Dark",
	ThemeMode.LIGHT: "Studio Light",
	ThemeMode.CYBERPUNK: "Neon Cyberpunk",
	ThemeMode.FANTASY: "Warm Fantasy",
	ThemeMode.SCIFI: "Holo Sci-Fi",
	ThemeMode.HISTORIC: "Antique Sepia",
	ThemeMode.JUNGLE: "Emerald Jungle",
	ThemeMode.OCEAN: "Abyss Ocean"
}

# 1. Authentic Organic Zen Palette (Inspired by River Stones, Golden Waves, & Bamboo)
const PALETTE_ZEN: Dictionary = {
	"bg_base": Color(0.055, 0.062, 0.075, 1.0),
	"panel_bg": Color(0.080, 0.095, 0.118, 0.82),
	"panel_border": Color(0.92, 0.76, 0.42, 0.42),
	"panel_border_glow": Color(1.0, 0.85, 0.50, 0.95),
	"btn_normal": Color(0.12, 0.145, 0.175, 0.85),
	"btn_hover": Color(0.96, 0.82, 0.48, 0.30),
	"btn_pressed": Color(0.85, 0.62, 0.35, 0.55),
	"btn_toggled": Color(0.18, 0.85, 0.60, 0.45),
	"primary": Color(0.96, 0.82, 0.46, 1.0),
	"secondary": Color(0.20, 0.88, 0.65, 1.0),
	"tertiary": Color(0.86, 0.62, 0.36, 1.0),
	"text_main": Color(0.96, 0.96, 0.92, 1.0),
	"text_dim": Color(0.68, 0.74, 0.70, 1.0),
	"canvas_bg": Color(0.048, 0.056, 0.070, 0.80),
	"canvas_grid": Color(0.92, 0.76, 0.42, 0.38),
	"canvas_radar_sweep": Color(0.20, 0.88, 0.65, 0.32),
	"node_glow": Color(0.96, 0.82, 0.46, 0.60),
	"node_selected": Color(0.20, 0.88, 0.65, 1.0)
}

# 2. Authentic Liquid Glass Dark Palette
const PALETTE_DARK: Dictionary = {
	"bg_base": Color(0.035, 0.048, 0.082, 1.0),
	"panel_bg": Color(0.055, 0.082, 0.155, 0.60),
	"panel_border": Color(0.25, 0.65, 0.95, 0.22),
	"panel_border_glow": Color(0.0, 0.949, 0.996, 0.85),
	"btn_normal": Color(0.08, 0.12, 0.22, 0.65),
	"btn_hover": Color(0.0, 0.85, 0.98, 0.20),
	"btn_pressed": Color(0.0, 0.75, 0.92, 0.35),
	"btn_toggled": Color(0.0, 0.65, 0.85, 0.28),
	"primary": Color(0.0, 0.949, 0.996, 1.0),
	"secondary": Color(0.31, 0.675, 0.996, 1.0),
	"tertiary": Color(0.965, 0.827, 0.396, 1.0),
	"text_main": Color(0.92, 0.95, 0.98, 1.0),
	"text_dim": Color(0.52, 0.58, 0.70, 1.0),
	"canvas_bg": Color(0.04, 0.06, 0.12, 0.50),
	"canvas_grid": Color(0.0, 0.949, 0.996, 0.20),
	"canvas_radar_sweep": Color(0.0, 0.949, 0.996, 0.25),
	"node_glow": Color(0.0, 0.949, 0.996, 0.40),
	"node_selected": Color(0.965, 0.827, 0.396, 1.0)
}

# 2. Authentic Liquid Glass Light Palette
const PALETTE_LIGHT: Dictionary = {
	"bg_base": Color(0.91, 0.93, 0.97, 1.0),
	"panel_bg": Color(1.0, 1.0, 1.0, 0.70),
	"panel_border": Color(0.65, 0.75, 0.88, 0.50),
	"panel_border_glow": Color(0.01, 0.52, 0.78, 0.80),
	"btn_normal": Color(0.96, 0.98, 1.0, 0.75),
	"btn_hover": Color(0.85, 0.94, 1.0, 0.95),
	"btn_pressed": Color(0.01, 0.52, 0.78, 0.25),
	"btn_toggled": Color(0.01, 0.52, 0.78, 0.20),
	"primary": Color(0.01, 0.52, 0.78, 1.0),
	"secondary": Color(0.15, 0.38, 0.92, 1.0),
	"tertiary": Color(0.85, 0.47, 0.02, 1.0),
	"text_main": Color(0.08, 0.12, 0.18, 1.0),
	"text_dim": Color(0.38, 0.44, 0.54, 1.0),
	"canvas_bg": Color(0.95, 0.97, 1.0, 0.60),
	"canvas_grid": Color(0.01, 0.52, 0.78, 0.22),
	"canvas_radar_sweep": Color(0.01, 0.52, 0.78, 0.18),
	"node_glow": Color(0.01, 0.52, 0.78, 0.30),
	"node_selected": Color(0.85, 0.47, 0.02, 1.0)
}

# 3. Cyberpunk Palette (Hot Neon Magenta & Cyan)
const PALETTE_CYBERPUNK: Dictionary = {
	"bg_base": Color(0.04, 0.02, 0.07, 1.0),
	"panel_bg": Color(0.09, 0.04, 0.14, 0.68),
	"panel_border": Color(1.0, 0.0, 0.55, 0.35),
	"panel_border_glow": Color(1.0, 0.0, 0.55, 0.90),
	"btn_normal": Color(0.14, 0.06, 0.22, 0.70),
	"btn_hover": Color(0.0, 0.95, 1.0, 0.30),
	"btn_pressed": Color(1.0, 0.0, 0.55, 0.40),
	"btn_toggled": Color(1.0, 0.0, 0.55, 0.30),
	"primary": Color(0.0, 0.95, 1.0, 1.0),
	"secondary": Color(1.0, 0.0, 0.55, 1.0),
	"tertiary": Color(1.0, 0.85, 0.0, 1.0),
	"text_main": Color(0.95, 0.92, 1.0, 1.0),
	"text_dim": Color(0.65, 0.50, 0.75, 1.0),
	"canvas_bg": Color(0.06, 0.02, 0.10, 0.65),
	"canvas_grid": Color(1.0, 0.0, 0.55, 0.25),
	"canvas_radar_sweep": Color(0.0, 0.95, 1.0, 0.30),
	"node_glow": Color(1.0, 0.0, 0.55, 0.45),
	"node_selected": Color(1.0, 0.85, 0.0, 1.0)
}

# 4. Fantasy Palette (Gold, Amber & Runes)
const PALETTE_FANTASY: Dictionary = {
	"bg_base": Color(0.07, 0.05, 0.04, 1.0),
	"panel_bg": Color(0.14, 0.09, 0.06, 0.65),
	"panel_border": Color(0.85, 0.65, 0.30, 0.35),
	"panel_border_glow": Color(1.0, 0.80, 0.20, 0.90),
	"btn_normal": Color(0.20, 0.14, 0.09, 0.70),
	"btn_hover": Color(1.0, 0.80, 0.20, 0.25),
	"btn_pressed": Color(0.85, 0.55, 0.15, 0.40),
	"btn_toggled": Color(0.85, 0.55, 0.15, 0.30),
	"primary": Color(1.0, 0.80, 0.25, 1.0),
	"secondary": Color(0.85, 0.55, 0.15, 1.0),
	"tertiary": Color(0.45, 0.85, 0.45, 1.0),
	"text_main": Color(0.98, 0.94, 0.88, 1.0),
	"text_dim": Color(0.70, 0.60, 0.50, 1.0),
	"canvas_bg": Color(0.10, 0.07, 0.04, 0.60),
	"canvas_grid": Color(0.85, 0.65, 0.30, 0.25),
	"canvas_radar_sweep": Color(1.0, 0.80, 0.25, 0.25),
	"node_glow": Color(1.0, 0.80, 0.25, 0.40),
	"node_selected": Color(0.45, 0.85, 0.45, 1.0)
}

# 5. Sci-Fi Palette (Deep Void & Electric Blue)
const PALETTE_SCIFI: Dictionary = {
	"bg_base": Color(0.01, 0.03, 0.06, 1.0),
	"panel_bg": Color(0.02, 0.06, 0.12, 0.65),
	"panel_border": Color(0.10, 0.45, 0.90, 0.30),
	"panel_border_glow": Color(0.15, 0.70, 1.0, 0.90),
	"btn_normal": Color(0.04, 0.10, 0.18, 0.70),
	"btn_hover": Color(0.15, 0.70, 1.0, 0.25),
	"btn_pressed": Color(0.10, 0.55, 0.95, 0.40),
	"btn_toggled": Color(0.10, 0.55, 0.95, 0.30),
	"primary": Color(0.15, 0.70, 1.0, 1.0),
	"secondary": Color(0.0, 0.45, 0.95, 1.0),
	"tertiary": Color(0.0, 1.0, 0.75, 1.0),
	"text_main": Color(0.90, 0.95, 1.0, 1.0),
	"text_dim": Color(0.45, 0.55, 0.70, 1.0),
	"canvas_bg": Color(0.02, 0.04, 0.09, 0.60),
	"canvas_grid": Color(0.15, 0.70, 1.0, 0.20),
	"canvas_radar_sweep": Color(0.15, 0.70, 1.0, 0.28),
	"node_glow": Color(0.15, 0.70, 1.0, 0.45),
	"node_selected": Color(0.0, 1.0, 0.75, 1.0)
}

# 6. Historic Sepia Palette
const PALETTE_HISTORIC: Dictionary = {
	"bg_base": Color(0.12, 0.09, 0.07, 1.0),
	"panel_bg": Color(0.18, 0.14, 0.10, 0.70),
	"panel_border": Color(0.60, 0.48, 0.35, 0.40),
	"panel_border_glow": Color(0.85, 0.68, 0.45, 0.85),
	"btn_normal": Color(0.24, 0.18, 0.14, 0.75),
	"btn_hover": Color(0.85, 0.68, 0.45, 0.25),
	"btn_pressed": Color(0.65, 0.48, 0.30, 0.40),
	"btn_toggled": Color(0.65, 0.48, 0.30, 0.30),
	"primary": Color(0.88, 0.72, 0.50, 1.0),
	"secondary": Color(0.70, 0.52, 0.35, 1.0),
	"tertiary": Color(0.95, 0.40, 0.30, 1.0),
	"text_main": Color(0.95, 0.90, 0.82, 1.0),
	"text_dim": Color(0.65, 0.55, 0.45, 1.0),
	"canvas_bg": Color(0.14, 0.11, 0.08, 0.65),
	"canvas_grid": Color(0.60, 0.48, 0.35, 0.28),
	"canvas_radar_sweep": Color(0.88, 0.72, 0.50, 0.22),
	"node_glow": Color(0.88, 0.72, 0.50, 0.35),
	"node_selected": Color(0.95, 0.40, 0.30, 1.0)
}

# 7. Jungle Palette (Rainforest Emerald & Sage)
const PALETTE_JUNGLE: Dictionary = {
	"bg_base": Color(0.02, 0.06, 0.04, 1.0),
	"panel_bg": Color(0.04, 0.12, 0.07, 0.65),
	"panel_border": Color(0.15, 0.65, 0.35, 0.30),
	"panel_border_glow": Color(0.20, 0.95, 0.50, 0.85),
	"btn_normal": Color(0.06, 0.18, 0.10, 0.70),
	"btn_hover": Color(0.20, 0.95, 0.50, 0.25),
	"btn_pressed": Color(0.15, 0.75, 0.40, 0.40),
	"btn_toggled": Color(0.15, 0.75, 0.40, 0.30),
	"primary": Color(0.20, 0.95, 0.50, 1.0),
	"secondary": Color(0.10, 0.70, 0.35, 1.0),
	"tertiary": Color(0.95, 0.80, 0.20, 1.0),
	"text_main": Color(0.90, 0.98, 0.92, 1.0),
	"text_dim": Color(0.48, 0.65, 0.52, 1.0),
	"canvas_bg": Color(0.03, 0.08, 0.05, 0.60),
	"canvas_grid": Color(0.15, 0.65, 0.35, 0.22),
	"canvas_radar_sweep": Color(0.20, 0.95, 0.50, 0.25),
	"node_glow": Color(0.20, 0.95, 0.50, 0.40),
	"node_selected": Color(0.95, 0.80, 0.20, 1.0)
}

# 8. Ocean Palette (Abyss Deep Navy & Aquamarine)
const PALETTE_OCEAN: Dictionary = {
	"bg_base": Color(0.01, 0.04, 0.08, 1.0),
	"panel_bg": Color(0.02, 0.08, 0.16, 0.65),
	"panel_border": Color(0.0, 0.60, 0.85, 0.30),
	"panel_border_glow": Color(0.0, 0.90, 0.90, 0.85),
	"btn_normal": Color(0.03, 0.12, 0.24, 0.70),
	"btn_hover": Color(0.0, 0.90, 0.90, 0.25),
	"btn_pressed": Color(0.0, 0.65, 0.85, 0.40),
	"btn_toggled": Color(0.0, 0.65, 0.85, 0.30),
	"primary": Color(0.0, 0.90, 0.90, 1.0),
	"secondary": Color(0.0, 0.50, 0.95, 1.0),
	"tertiary": Color(0.70, 0.40, 1.0, 1.0),
	"text_main": Color(0.90, 0.96, 1.0, 1.0),
	"text_dim": Color(0.45, 0.60, 0.75, 1.0),
	"canvas_bg": Color(0.02, 0.05, 0.11, 0.60),
	"canvas_grid": Color(0.0, 0.60, 0.85, 0.22),
	"canvas_radar_sweep": Color(0.0, 0.90, 0.90, 0.26),
	"node_glow": Color(0.0, 0.90, 0.90, 0.40),
	"node_selected": Color(0.70, 0.40, 1.0, 1.0)
}

static func get_palette_for_mode(mode: ThemeMode) -> Dictionary:
	match mode:
		ThemeMode.ZEN: return PALETTE_ZEN
		ThemeMode.DARK: return PALETTE_DARK
		ThemeMode.LIGHT: return PALETTE_LIGHT
		ThemeMode.CYBERPUNK: return PALETTE_CYBERPUNK
		ThemeMode.FANTASY: return PALETTE_FANTASY
		ThemeMode.SCIFI: return PALETTE_SCIFI
		ThemeMode.HISTORIC: return PALETTE_HISTORIC
		ThemeMode.JUNGLE: return PALETTE_JUNGLE
		ThemeMode.OCEAN: return PALETTE_OCEAN
	return PALETTE_ZEN

static func get_palette() -> Dictionary:
	return get_palette_for_mode(current_theme)

static func is_dark_mode(mode: ThemeMode = current_theme) -> bool:
	return mode != ThemeMode.LIGHT

static func get_sound_icon(icon_name: String, force_dark_icon: bool = false) -> Texture2D:
	var use_light_set: bool = (current_theme == ThemeMode.LIGHT) and not force_dark_icon
	var subfolder: String = "light" if use_light_set else "dark"
	var path: String = "res://assets/icons/sound_icons/%s/%s.svg" % [subfolder, icon_name]
	if ResourceLoader.exists(path):
		return load(path)
	var fallback_subfolder: String = "light" if force_dark_icon or current_theme == ThemeMode.LIGHT else "dark"
	return load("res://assets/icons/sound_icons/%s/volume.svg" % fallback_subfolder)

static func create_theme(mode: ThemeMode) -> Theme:
	var pal: Dictionary = get_palette_for_mode(mode)
	var theme: Theme = Theme.new()
	var is_zen: bool = (mode == ThemeMode.ZEN)

	# 1. PanelContainer (Textured Basalt Slate Glass for Zen)
	var panel_sb: StyleBox
	if is_zen and ResourceLoader.exists("res://assets/textures/zen/panel_slate_glass.png"):
		var p_tex: StyleBoxTexture = StyleBoxTexture.new()
		p_tex.texture = load("res://assets/textures/zen/panel_slate_glass.png")
		p_tex.texture_margin_left = 12
		p_tex.texture_margin_right = 12
		p_tex.texture_margin_top = 12
		p_tex.texture_margin_bottom = 12
		p_tex.content_margin_left = 10
		p_tex.content_margin_right = 10
		p_tex.content_margin_top = 8
		p_tex.content_margin_bottom = 8
		panel_sb = p_tex
	else:
		var p_flat: StyleBoxFlat = StyleBoxFlat.new()
		p_flat.bg_color = pal["panel_bg"]
		p_flat.set_border_width_all(1)
		p_flat.border_color = pal["panel_border"]
		p_flat.border_width_top = 1
		p_flat.set_corner_radius_all(8)
		p_flat.content_margin_left = 8
		p_flat.content_margin_right = 8
		p_flat.content_margin_top = 6
		p_flat.content_margin_bottom = 6
		p_flat.shadow_color = Color(0.0, 0.2, 0.4, 0.08)
		p_flat.shadow_size = 8
		panel_sb = p_flat
	theme.set_stylebox("panel", "PanelContainer", panel_sb)

	# 2. Button Normal (Textured Slate Pebble)
	var btn_normal: StyleBox
	if is_zen and ResourceLoader.exists("res://assets/textures/zen/btn_slate_normal.png"):
		var b_tex: StyleBoxTexture = StyleBoxTexture.new()
		b_tex.texture = load("res://assets/textures/zen/btn_slate_normal.png")
		b_tex.texture_margin_left = 10
		b_tex.texture_margin_right = 10
		b_tex.texture_margin_top = 10
		b_tex.texture_margin_bottom = 10
		b_tex.content_margin_left = 10
		b_tex.content_margin_right = 10
		b_tex.content_margin_top = 5
		b_tex.content_margin_bottom = 5
		btn_normal = b_tex
	else:
		var b_flat: StyleBoxFlat = StyleBoxFlat.new()
		b_flat.bg_color = pal["btn_normal"]
		b_flat.set_border_width_all(1)
		b_flat.border_color = pal["panel_border"]
		b_flat.set_corner_radius_all(5)
		b_flat.content_margin_left = 8
		b_flat.content_margin_right = 8
		b_flat.content_margin_top = 4
		b_flat.content_margin_bottom = 4
		btn_normal = b_flat
	theme.set_stylebox("normal", "Button", btn_normal)

	# 3. Button Hover (Glowing Golden Amber Slate Rim)
	var btn_hover: StyleBox
	if is_zen and ResourceLoader.exists("res://assets/textures/zen/btn_slate_hover.png"):
		var bh_tex: StyleBoxTexture = StyleBoxTexture.new()
		bh_tex.texture = load("res://assets/textures/zen/btn_slate_hover.png")
		bh_tex.texture_margin_left = 10
		bh_tex.texture_margin_right = 10
		bh_tex.texture_margin_top = 10
		bh_tex.texture_margin_bottom = 10
		bh_tex.content_margin_left = 10
		bh_tex.content_margin_right = 10
		bh_tex.content_margin_top = 5
		bh_tex.content_margin_bottom = 5
		btn_hover = bh_tex
	else:
		var bh_flat: StyleBoxFlat = StyleBoxFlat.new()
		bh_flat.bg_color = pal["btn_hover"]
		bh_flat.set_border_width_all(1)
		bh_flat.border_color = pal["panel_border_glow"]
		bh_flat.set_corner_radius_all(5)
		bh_flat.content_margin_left = 8
		bh_flat.content_margin_right = 8
		bh_flat.content_margin_top = 4
		bh_flat.content_margin_bottom = 4
		btn_hover = bh_flat
	theme.set_stylebox("hover", "Button", btn_hover)

	# 4. Button Pressed / Toggled (Warm Polished Bamboo Wood)
	var btn_pressed: StyleBox
	if is_zen and ResourceLoader.exists("res://assets/textures/zen/btn_bamboo_pressed.png"):
		var bp_tex: StyleBoxTexture = StyleBoxTexture.new()
		bp_tex.texture = load("res://assets/textures/zen/btn_bamboo_pressed.png")
		bp_tex.texture_margin_left = 10
		bp_tex.texture_margin_right = 10
		bp_tex.texture_margin_top = 10
		bp_tex.texture_margin_bottom = 10
		bp_tex.content_margin_left = 10
		bp_tex.content_margin_right = 10
		bp_tex.content_margin_top = 5
		bp_tex.content_margin_bottom = 5
		btn_pressed = bp_tex
	else:
		var bp_flat: StyleBoxFlat = StyleBoxFlat.new()
		bp_flat.bg_color = pal["btn_pressed"]
		bp_flat.set_border_width_all(2)
		bp_flat.border_color = pal["panel_border_glow"]
		bp_flat.set_corner_radius_all(5)
		bp_flat.content_margin_left = 8
		bp_flat.content_margin_right = 8
		bp_flat.content_margin_top = 4
		bp_flat.content_margin_bottom = 4
		btn_pressed = bp_flat
	theme.set_stylebox("pressed", "Button", btn_pressed)

	# 5. LineEdit / Text Inputs
	var line_edit_sb: StyleBoxFlat = StyleBoxFlat.new()
	line_edit_sb.bg_color = pal["btn_normal"]
	line_edit_sb.set_border_width_all(1)
	line_edit_sb.border_color = pal["panel_border"]
	line_edit_sb.set_corner_radius_all(5)
	line_edit_sb.content_margin_left = 8
	line_edit_sb.content_margin_right = 8
	line_edit_sb.content_margin_top = 4
	line_edit_sb.content_margin_bottom = 4
	theme.set_stylebox("normal", "LineEdit", line_edit_sb)
	theme.set_stylebox("focus", "LineEdit", btn_hover)

	# 6. Global Typography and Font Colors
	theme.set_color("font_color", "Label", pal["text_main"])
	theme.set_color("font_color", "Button", pal["text_main"])
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", pal["primary"])
	theme.set_color("font_hover_pressed_color", "Button", Color.WHITE)
	theme.set_color("font_focus_color", "Button", pal["text_main"])
	theme.set_color("font_color", "LineEdit", pal["text_main"])
	theme.set_color("font_placeholder_color", "LineEdit", pal["text_dim"])

	# CheckButton Styling
	var cb_normal: StyleBoxFlat = StyleBoxFlat.new()
	cb_normal.bg_color = pal["btn_normal"]
	cb_normal.set_border_width_all(1)
	cb_normal.border_color = pal["panel_border"]
	cb_normal.set_corner_radius_all(5)
	cb_normal.content_margin_left = 8
	cb_normal.content_margin_right = 8
	cb_normal.content_margin_top = 4
	cb_normal.content_margin_bottom = 4
	theme.set_stylebox("normal", "CheckButton", cb_normal)
	theme.set_stylebox("hover", "CheckButton", btn_hover)
	theme.set_stylebox("pressed", "CheckButton", btn_pressed)
	theme.set_color("font_color", "CheckButton", pal["text_main"])
	theme.set_color("font_pressed_color", "CheckButton", pal["primary"])
	theme.set_color("font_hover_color", "CheckButton", Color.WHITE)

	# 7. MenuBar Styling (Native Desktop Menu Bar)
	var menubar_normal: StyleBoxEmpty = StyleBoxEmpty.new()
	var menubar_hover: StyleBoxFlat = StyleBoxFlat.new()
	menubar_hover.bg_color = Color(1.0, 1.0, 1.0, 0.08)
	menubar_hover.set_corner_radius_all(4)
	menubar_hover.content_margin_left = 8
	menubar_hover.content_margin_right = 8
	menubar_hover.content_margin_top = 3
	menubar_hover.content_margin_bottom = 3

	var menubar_pressed: StyleBoxFlat = StyleBoxFlat.new()
	menubar_pressed.bg_color = Color(1.0, 1.0, 1.0, 0.15)
	menubar_pressed.set_corner_radius_all(4)
	menubar_pressed.content_margin_left = 8
	menubar_pressed.content_margin_right = 8
	menubar_pressed.content_margin_top = 3
	menubar_pressed.content_margin_bottom = 3

	theme.set_stylebox("normal", "MenuBar", menubar_normal)
	theme.set_stylebox("hover", "MenuBar", menubar_hover)
	theme.set_stylebox("pressed", "MenuBar", menubar_pressed)
	theme.set_color("font_color", "MenuBar", pal["text_main"])
	theme.set_color("font_hover_color", "MenuBar", Color.WHITE)
	theme.set_color("font_pressed_color", "MenuBar", pal["primary"])

	# 8. PopupMenu Styling (Desktop Dropdown Menus)
	var popup_panel: StyleBoxFlat = StyleBoxFlat.new()
	popup_panel.bg_color = Color(0.10, 0.12, 0.17, 0.98) if mode != ThemeMode.LIGHT else Color(0.96, 0.97, 0.99, 0.98)
	popup_panel.set_border_width_all(1)
	popup_panel.border_color = pal["panel_border"]
	popup_panel.set_corner_radius_all(6)
	popup_panel.content_margin_left = 6
	popup_panel.content_margin_right = 6
	popup_panel.content_margin_top = 6
	popup_panel.content_margin_bottom = 6
	popup_panel.shadow_color = Color(0.0, 0.0, 0.0, 0.4)
	popup_panel.shadow_size = 14

	var popup_hover: StyleBoxFlat = StyleBoxFlat.new()
	popup_hover.bg_color = Color(pal["primary"].r, pal["primary"].g, pal["primary"].b, 0.25)
	popup_hover.set_corner_radius_all(4)
	popup_hover.content_margin_left = 8
	popup_hover.content_margin_right = 8
	popup_hover.content_margin_top = 4
	popup_hover.content_margin_bottom = 4

	var popup_sep: StyleBoxLine = StyleBoxLine.new()
	popup_sep.color = pal["panel_border"]
	popup_sep.thickness = 1
	popup_sep.content_margin_top = 4
	popup_sep.content_margin_bottom = 4

	theme.set_stylebox("panel", "PopupMenu", popup_panel)
	theme.set_stylebox("hover", "PopupMenu", popup_hover)
	theme.set_stylebox("separator", "PopupMenu", popup_sep)
	theme.set_color("font_color", "PopupMenu", pal["text_main"])
	theme.set_color("font_hover_color", "PopupMenu", Color.WHITE)
	theme.set_color("font_accelerator_color", "PopupMenu", pal["text_dim"])
	theme.set_color("font_disabled_color", "PopupMenu", Color(0.4, 0.45, 0.55))
	theme.set_color("font_separator_color", "PopupMenu", pal["text_dim"])
	theme.set_constant("v_separation", "PopupMenu", 5)
	theme.set_constant("h_separation", "PopupMenu", 8)

	# 9. Window & Dialog Styling
	var win_border: StyleBoxFlat = StyleBoxFlat.new()
	win_border.bg_color = pal["bg_base"]
	win_border.set_border_width_all(1)
	win_border.border_color = pal["panel_border_glow"]
	win_border.set_corner_radius_all(10)
	win_border.expand_margin_top = 28
	win_border.expand_margin_bottom = 2
	win_border.expand_margin_left = 2
	win_border.expand_margin_right = 2
	win_border.content_margin_left = 12
	win_border.content_margin_right = 12
	win_border.content_margin_top = 10
	win_border.content_margin_bottom = 10
	win_border.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	win_border.shadow_size = 16

	theme.set_stylebox("embedded_border", "Window", win_border)
	theme.set_stylebox("embedded_unfocused_border", "Window", win_border)
	theme.set_color("title_color", "Window", pal["text_main"])
	theme.set_color("title_outline_modulate", "Window", Color.TRANSPARENT)
	theme.set_font_size("title_font_size", "Window", 13)

	# Dialog backgrounds & panels
	theme.set_stylebox("panel", "AcceptDialog", win_border)
	theme.set_stylebox("panel", "ConfirmationDialog", win_border)
	theme.set_stylebox("panel", "FileDialog", win_border)
	theme.set_stylebox("panel", "PopupPanel", popup_panel)

	# FileDialog Specific Styling
	theme.set_stylebox("embedded_border", "FileDialog", win_border)
	theme.set_stylebox("embedded_unfocused_border", "FileDialog", win_border)
	theme.set_stylebox("embedded_border", "AcceptDialog", win_border)
	theme.set_stylebox("embedded_unfocused_border", "AcceptDialog", win_border)
	theme.set_stylebox("embedded_border", "ConfirmationDialog", win_border)
	theme.set_stylebox("embedded_unfocused_border", "ConfirmationDialog", win_border)

	theme.set_color("folder_icon_color", "FileDialog", pal["primary"])
	theme.set_color("file_icon_color", "FileDialog", pal["secondary"])
	theme.set_color("file_disabled_color", "FileDialog", pal["text_dim"])

	# 10. ProgressBar Styling
	var pb_bg: StyleBoxFlat = StyleBoxFlat.new()
	pb_bg.bg_color = pal["btn_normal"]
	pb_bg.set_corner_radius_all(4)
	var pb_fg: StyleBoxFlat = StyleBoxFlat.new()
	pb_fg.bg_color = pal["primary"]
	pb_fg.set_corner_radius_all(4)
	theme.set_stylebox("background", "ProgressBar", pb_bg)
	theme.set_stylebox("fill", "ProgressBar", pb_fg)
	theme.set_color("font_color", "ProgressBar", pal["text_main"])

	# 11. Scrollbar Styling
	var scroll_grabber: StyleBoxFlat = StyleBoxFlat.new()
	scroll_grabber.bg_color = pal["panel_border"]
	scroll_grabber.set_corner_radius_all(4)
	var scroll_grabber_hl: StyleBoxFlat = StyleBoxFlat.new()
	scroll_grabber_hl.bg_color = pal["primary"]
	scroll_grabber_hl.set_corner_radius_all(4)
	var scroll_bg: StyleBoxEmpty = StyleBoxEmpty.new()

	theme.set_stylebox("grabber", "VScrollBar", scroll_grabber)
	theme.set_stylebox("grabber_highlight", "VScrollBar", scroll_grabber_hl)
	theme.set_stylebox("grabber_pressed", "VScrollBar", scroll_grabber_hl)
	theme.set_stylebox("scroll", "VScrollBar", scroll_bg)

	theme.set_stylebox("grabber", "HScrollBar", scroll_grabber)
	theme.set_stylebox("grabber_highlight", "HScrollBar", scroll_grabber_hl)
	theme.set_stylebox("grabber_pressed", "HScrollBar", scroll_grabber_hl)
	theme.set_stylebox("scroll", "HScrollBar", scroll_bg)

	# 12. TabContainer & TabBar Styling
	var tab_selected_sb: StyleBoxFlat = StyleBoxFlat.new()
	tab_selected_sb.bg_color = pal["btn_pressed"]
	tab_selected_sb.set_border_width_all(1)
	tab_selected_sb.border_color = pal["panel_border_glow"]
	tab_selected_sb.set_corner_radius_all(6)
	tab_selected_sb.content_margin_left = 12
	tab_selected_sb.content_margin_right = 12
	tab_selected_sb.content_margin_top = 6
	tab_selected_sb.content_margin_bottom = 6

	var tab_unselected_sb: StyleBoxFlat = StyleBoxFlat.new()
	tab_unselected_sb.bg_color = pal["btn_normal"]
	tab_unselected_sb.set_border_width_all(1)
	tab_unselected_sb.border_color = pal["panel_border"]
	tab_unselected_sb.set_corner_radius_all(6)
	tab_unselected_sb.content_margin_left = 12
	tab_unselected_sb.content_margin_right = 12
	tab_unselected_sb.content_margin_top = 6
	tab_unselected_sb.content_margin_bottom = 6

	var tab_hover_sb: StyleBoxFlat = StyleBoxFlat.new()
	tab_hover_sb.bg_color = pal["btn_hover"]
	tab_hover_sb.set_border_width_all(1)
	tab_hover_sb.border_color = pal["panel_border_glow"]
	tab_hover_sb.set_corner_radius_all(6)
	tab_hover_sb.content_margin_left = 12
	tab_hover_sb.content_margin_right = 12
	tab_hover_sb.content_margin_top = 6
	tab_hover_sb.content_margin_bottom = 6

	theme.set_stylebox("tab_selected", "TabContainer", tab_selected_sb)
	theme.set_stylebox("tab_unselected", "TabContainer", tab_unselected_sb)
	theme.set_stylebox("tab_hovered", "TabContainer", tab_hover_sb)
	theme.set_stylebox("panel", "TabContainer", panel_sb)
	theme.set_color("font_selected_color", "TabContainer", pal["primary"])
	theme.set_color("font_unselected_color", "TabContainer", pal["text_dim"])
	theme.set_color("font_hovered_color", "TabContainer", Color.WHITE)

	theme.set_stylebox("tab_selected", "TabBar", tab_selected_sb)
	theme.set_stylebox("tab_unselected", "TabBar", tab_unselected_sb)
	theme.set_stylebox("tab_hovered", "TabBar", tab_hover_sb)
	theme.set_color("font_selected_color", "TabBar", pal["primary"])
	theme.set_color("font_unselected_color", "TabBar", pal["text_dim"])
	theme.set_color("font_hovered_color", "TabBar", Color.WHITE)

	# 13. OptionButton & CheckBox
	theme.set_stylebox("normal", "OptionButton", btn_normal)
	theme.set_stylebox("hover", "OptionButton", btn_hover)
	theme.set_stylebox("pressed", "OptionButton", btn_pressed)
	theme.set_stylebox("focus", "OptionButton", btn_hover)
	theme.set_color("font_color", "OptionButton", pal["text_main"])
	theme.set_color("font_hover_color", "OptionButton", Color.WHITE)
	theme.set_color("font_pressed_color", "OptionButton", pal["primary"])

	theme.set_color("font_color", "CheckBox", pal["text_main"])
	theme.set_color("font_hover_color", "CheckBox", Color.WHITE)
	theme.set_color("font_pressed_color", "CheckBox", pal["primary"])
	theme.set_color("font_focus_color", "CheckBox", pal["primary"])

	# 14. Tree & ItemList (FileDialog Internals & List Pickers)
	var tree_panel: StyleBoxFlat = StyleBoxFlat.new()
	tree_panel.bg_color = pal["btn_normal"]
	tree_panel.set_border_width_all(1)
	tree_panel.border_color = pal["panel_border"]
	tree_panel.set_corner_radius_all(6)
	tree_panel.content_margin_left = 8
	tree_panel.content_margin_right = 8
	tree_panel.content_margin_top = 8
	tree_panel.content_margin_bottom = 8

	theme.set_stylebox("panel", "Tree", tree_panel)
	theme.set_stylebox("focus", "Tree", btn_hover)
	theme.set_stylebox("hovered", "Tree", btn_hover)
	theme.set_stylebox("hovered_dimmed", "Tree", btn_hover)
	theme.set_stylebox("hovered_selected", "Tree", popup_hover)
	theme.set_stylebox("hovered_selected_focus", "Tree", popup_hover)
	theme.set_stylebox("selected", "Tree", popup_hover)
	theme.set_stylebox("selected_focus", "Tree", popup_hover)
	theme.set_stylebox("cursor", "Tree", btn_hover)
	theme.set_stylebox("cursor_unfocused", "Tree", tree_panel)
	theme.set_stylebox("title_button_normal", "Tree", btn_normal)
	theme.set_stylebox("title_button_hover", "Tree", btn_hover)
	theme.set_stylebox("title_button_pressed", "Tree", btn_pressed)
	theme.set_color("font_color", "Tree", pal["text_main"])
	theme.set_color("font_selected_color", "Tree", Color.WHITE)
	theme.set_color("font_hovered_color", "Tree", Color.WHITE)
	theme.set_color("font_hovered_dimmed_color", "Tree", pal["text_main"])
	theme.set_color("font_disabled_color", "Tree", pal["text_dim"])
	theme.set_color("title_button_color", "Tree", pal["primary"])
	theme.set_color("guide_color", "Tree", Color(pal["panel_border"].r, pal["panel_border"].g, pal["panel_border"].b, 0.3))
	theme.set_color("relationship_line_color", "Tree", pal["panel_border"])
	theme.set_color("drop_position_color", "Tree", pal["primary"])
	theme.set_constant("draw_relationship_lines", "Tree", 1)
	theme.set_constant("draw_guides", "Tree", 1)
	theme.set_constant("item_margin", "Tree", 4)
	theme.set_constant("h_separation", "Tree", 6)
	theme.set_constant("v_separation", "Tree", 4)

	theme.set_stylebox("panel", "ItemList", tree_panel)
	theme.set_stylebox("focus", "ItemList", btn_hover)
	theme.set_stylebox("hovered", "ItemList", btn_hover)
	theme.set_stylebox("hovered_selected", "ItemList", popup_hover)
	theme.set_stylebox("selected", "ItemList", popup_hover)
	theme.set_stylebox("selected_focus", "ItemList", popup_hover)
	theme.set_stylebox("cursor", "ItemList", btn_hover)
	theme.set_stylebox("cursor_unfocused", "ItemList", tree_panel)
	theme.set_color("font_color", "ItemList", pal["text_main"])
	theme.set_color("font_selected_color", "ItemList", Color.WHITE)
	theme.set_color("font_hovered_color", "ItemList", Color.WHITE)
	theme.set_color("guide_color", "ItemList", Color(pal["panel_border"].r, pal["panel_border"].g, pal["panel_border"].b, 0.3))
	theme.set_constant("h_separation", "ItemList", 6)
	theme.set_constant("v_separation", "ItemList", 4)

	# Button Icons
	theme.set_color("icon_normal_color", "Button", pal["text_main"])
	theme.set_color("icon_hover_color", "Button", Color.WHITE)
	theme.set_color("icon_pressed_color", "Button", pal["primary"])
	theme.set_color("icon_disabled_color", "Button", pal["text_dim"])

	# 16. Separators
	var sep_sb: StyleBoxLine = StyleBoxLine.new()
	sep_sb.color = pal["panel_border"]
	sep_sb.thickness = 1
	theme.set_stylebox("separator", "HSeparator", sep_sb)
	theme.set_stylebox("separator", "VSeparator", sep_sb)

	# 17. Sliders (Volume, Distance, Speed)
	var slider_track: StyleBoxFlat = StyleBoxFlat.new()
	slider_track.bg_color = pal["btn_normal"]
	slider_track.set_border_width_all(1)
	slider_track.border_color = pal["panel_border"]
	slider_track.set_corner_radius_all(3)
	slider_track.content_margin_top = 4
	slider_track.content_margin_bottom = 4
	theme.set_stylebox("slider", "HSlider", slider_track)

	var slider_fill: StyleBoxFlat = StyleBoxFlat.new()
	slider_fill.bg_color = pal["primary"]
	slider_fill.set_corner_radius_all(3)
	theme.set_stylebox("grabber_area", "HSlider", slider_fill)
	theme.set_stylebox("grabber_area_highlight", "HSlider", slider_fill)

	return theme

static func apply_theme(target: Node, mode: ThemeMode) -> void:
	current_theme = mode
	var t: Theme = create_theme(mode)
	_apply_theme_recursive(target, t)

static func _apply_theme_recursive(node: Node, t: Theme) -> void:
	if node is Window:
		(node as Window).theme = t
	elif node is Control:
		(node as Control).theme = t

	for child in node.get_children():
		_apply_theme_recursive(child, t)

static func get_bg_color() -> Color:
	var pal: Dictionary = get_palette()
	return pal.get("bg_base", Color(0.035, 0.048, 0.082, 1.0))

static func get_orb_colors(mode: ThemeMode) -> Dictionary:
	match mode:
		ThemeMode.ZEN:
			return {
				"bg": Color(0.042, 0.048, 0.060, 1.0),
				"orb1": Color(0.96, 0.82, 0.48, 0.32),
				"orb2": Color(0.18, 0.80, 0.60, 0.26),
				"orb3": Color(0.80, 0.58, 0.35, 0.20)
			}
		ThemeMode.DARK:
			return {
				"bg": Color(0.035, 0.048, 0.082, 1.0),
				"orb1": Color(0.0, 0.55, 0.95, 0.35),
				"orb2": Color(0.45, 0.15, 0.85, 0.28),
				"orb3": Color(0.0, 0.85, 0.8, 0.22)
			}
		ThemeMode.LIGHT:
			return {
				"bg": Color(0.91, 0.93, 0.97, 1.0),
				"orb1": Color(0.2, 0.6, 0.95, 0.25),
				"orb2": Color(0.6, 0.4, 0.9, 0.20),
				"orb3": Color(0.1, 0.8, 0.8, 0.18)
			}
		ThemeMode.CYBERPUNK:
			return {
				"bg": Color(0.04, 0.02, 0.07, 1.0),
				"orb1": Color(1.0, 0.0, 0.55, 0.38),
				"orb2": Color(0.0, 0.95, 1.0, 0.32),
				"orb3": Color(0.6, 0.0, 1.0, 0.25)
			}
		ThemeMode.FANTASY:
			return {
				"bg": Color(0.07, 0.05, 0.04, 1.0),
				"orb1": Color(1.0, 0.75, 0.2, 0.35),
				"orb2": Color(0.85, 0.45, 0.1, 0.28),
				"orb3": Color(0.3, 0.75, 0.35, 0.22)
			}
		ThemeMode.SCIFI:
			return {
				"bg": Color(0.01, 0.03, 0.06, 1.0),
				"orb1": Color(0.1, 0.7, 1.0, 0.40),
				"orb2": Color(0.0, 0.3, 0.9, 0.30),
				"orb3": Color(0.0, 1.0, 0.8, 0.25)
			}
		ThemeMode.HISTORIC:
			return {
				"bg": Color(0.12, 0.09, 0.07, 1.0),
				"orb1": Color(0.85, 0.65, 0.4, 0.32),
				"orb2": Color(0.6, 0.4, 0.2, 0.25),
				"orb3": Color(0.7, 0.55, 0.3, 0.20)
			}
		ThemeMode.JUNGLE:
			return {
				"bg": Color(0.03, 0.07, 0.04, 1.0),
				"orb1": Color(0.15, 0.9, 0.45, 0.35),
				"orb2": Color(0.0, 0.6, 0.3, 0.28),
				"orb3": Color(0.8, 0.85, 0.2, 0.22)
			}
		ThemeMode.OCEAN:
			return {
				"bg": Color(0.01, 0.04, 0.08, 1.0),
				"orb1": Color(0.0, 0.85, 0.9, 0.38),
				"orb2": Color(0.0, 0.4, 0.9, 0.32),
				"orb3": Color(0.4, 0.2, 0.9, 0.25)
			}
	return {
		"bg": Color(0.035, 0.048, 0.082, 1.0),
		"orb1": Color(0.0, 0.55, 0.95, 0.35),
		"orb2": Color(0.45, 0.15, 0.85, 0.28),
		"orb3": Color(0.0, 0.85, 0.8, 0.22)
	}

