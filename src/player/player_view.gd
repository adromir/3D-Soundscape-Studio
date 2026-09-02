class_name PlayerView
extends Control

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

var current_project: SoundscapeData.SoundscapeProject = null
var spatial_engine: SpatialEngine = null
var lighting_engine: LightingEngine = null

var soundscape_list: Array[Dictionary] = []
var current_soundscape_idx: int = -1

# Sleep Timer
var sleep_timer_total_sec: float = 0.0
var sleep_timer_remaining_sec: float = 0.0
var sleep_timer_active: bool = false
var fade_out_active: bool = false
var fade_duration_sec: float = 15.0

# UI Controls - Top Bar
var btn_library: Button = null
var btn_sleep_timer: Button = null
var btn_light_toggle: Button = null
var btn_settings: Button = null

# UI Controls - Center Artwork & Info
var cover_rect: TextureRect = null
var cover_panel: PanelContainer = null
var lbl_title: Label = null
var lbl_meta: Label = null
var halo_glow_rect: ColorRect = null

# UI Controls - Transport
var btn_prev: Button = null
var btn_play_pause: Button = null
var btn_next: Button = null
var btn_loop: Button = null
var slider_master_vol: HSlider = null
var btn_mute: Button = null

# UI Controls - Atmosphere Stem Mixer Drawer
var mixer_drawer: PanelContainer = null
var btn_toggle_mixer: Button = null
var scroll_stems: ScrollContainer = null
var stems_container: HBoxContainer = null
var mixer_expanded: bool = false

# Overlays / Dialogs
var library_overlay: PanelContainer = null
var sleep_overlay: PanelContainer = null
var settings_overlay: PanelContainer = null
var package_file_dialog: FileDialog = null

var _halo_pulse_time: float = 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# 1. Initialize Engines
	spatial_engine = SpatialEngine.new()
	spatial_engine.name = "PlayerSpatialEngine"
	add_child(spatial_engine)
	spatial_engine.track_triggered.connect(_on_track_triggered)
	spatial_engine.playback_state_changed.connect(_on_playback_state_changed)

	lighting_engine = LightingEngine.new()
	lighting_engine.name = "PlayerLightingEngine"
	add_child(lighting_engine)

	# 2. Build UI Hierarchy
	_build_ui()
	_apply_theme()

	# 3. Load Library Soundscapes
	refresh_library()

	# 4. Auto-load first soundscape if available
	if not soundscape_list.is_empty():
		load_soundscape_by_index(0)

func _process(delta: float) -> void:
	# Sleep Timer update
	if sleep_timer_active:
		sleep_timer_remaining_sec -= delta
		if sleep_timer_remaining_sec <= fade_duration_sec and not fade_out_active and spatial_engine.is_playing:
			fade_out_active = true

		if fade_out_active and sleep_timer_remaining_sec > 0:
			var fade_factor: float = clampf(sleep_timer_remaining_sec / fade_duration_sec, 0.0, 1.0)
			if current_project:
				spatial_engine.set_master_volume(current_project.master_volume * fade_factor)

		if sleep_timer_remaining_sec <= 0.0:
			sleep_timer_active = false
			fade_out_active = false
			spatial_engine.stop_playback()
			if lighting_engine:
				lighting_engine.stop_playback()
			_update_timer_button_ui()

		_update_timer_button_ui()

	# Halo visualizer breathing animation
	if spatial_engine and spatial_engine.is_playing:
		_halo_pulse_time += delta
		var pulse: float = (sin(_halo_pulse_time * 2.2) * 0.5 + 0.5) * 0.25 + 0.75
		if halo_glow_rect:
			halo_glow_rect.modulate.a = pulse * 0.4
	else:
		if halo_glow_rect:
			halo_glow_rect.modulate.a = 0.05

	# Update lighting engine frame
	if lighting_engine and spatial_engine and spatial_engine.is_playing:
		lighting_engine.update_frame(delta, spatial_engine.get_listener_position())

func _build_ui() -> void:
	# Background
	var bg: ColorRect = ColorRect.new()
	bg.name = "PlayerBackground"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.06, 0.07, 0.09)
	add_child(bg)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)

	# 1. Header Bar
	var header: PanelContainer = PanelContainer.new()
	var header_sb: StyleBoxFlat = StyleBoxFlat.new()
	header_sb.bg_color = Color(0.09, 0.10, 0.13, 0.95)
	header_sb.border_width_bottom = 1
	header_sb.border_color = Color(0.2, 0.22, 0.28, 0.5)
	header_sb.content_margin_left = 16
	header_sb.content_margin_right = 16
	header_sb.content_margin_top = 10
	header_sb.content_margin_bottom = 10
	header.add_theme_stylebox_override("panel", header_sb)
	main_vbox.add_child(header)

	var header_hbox: HBoxContainer = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 12)
	header.add_child(header_hbox)

	btn_library = Button.new()
	btn_library.text = " Library"
	btn_library.icon = load("res://assets/icons/library.svg")
	btn_library.custom_minimum_size = Vector2(100, 32)
	btn_library.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_library.pressed.connect(_toggle_library_overlay)
	header_hbox.add_child(btn_library)

	var app_lbl: Label = Label.new()
	app_lbl.text = "3D Ambient Player"
	app_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	app_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	app_lbl.add_theme_font_size_override("font_size", 14)
	app_lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.55))
	header_hbox.add_child(app_lbl)

	btn_sleep_timer = Button.new()
	btn_sleep_timer.text = " Timer"
	btn_sleep_timer.icon = load("res://assets/icons/moon.svg")
	btn_sleep_timer.custom_minimum_size = Vector2(90, 32)
	btn_sleep_timer.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_sleep_timer.pressed.connect(_toggle_sleep_overlay)
	header_hbox.add_child(btn_sleep_timer)

	btn_light_toggle = Button.new()
	btn_light_toggle.tooltip_text = "Toggle Smart Lighting (Philips Hue / Home Assistant)"
	btn_light_toggle.icon = load("res://assets/icons/light.svg")
	btn_light_toggle.custom_minimum_size = Vector2(36, 32)
	btn_light_toggle.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_light_toggle.pressed.connect(_toggle_smart_lighting)
	header_hbox.add_child(btn_light_toggle)

	btn_settings = Button.new()
	btn_settings.tooltip_text = "Settings (Theme, Audio, Language)"
	btn_settings.icon = load("res://assets/icons/settings.svg")
	btn_settings.custom_minimum_size = Vector2(36, 32)
	btn_settings.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_settings.pressed.connect(_toggle_settings_overlay)
	header_hbox.add_child(btn_settings)

	# 2. Center Stage (Artwork & Titles)
	var center_stage: MarginContainer = MarginContainer.new()
	center_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_stage.add_theme_constant_override("margin_left", 24)
	center_stage.add_theme_constant_override("margin_right", 24)
	center_stage.add_theme_constant_override("margin_top", 20)
	center_stage.add_theme_constant_override("margin_bottom", 20)
	main_vbox.add_child(center_stage)

	var center_vbox: VBoxContainer = VBoxContainer.new()
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_vbox.add_theme_constant_override("separation", 16)
	center_stage.add_child(center_vbox)

	# Glowing Cover Container
	var cover_center: CenterContainer = CenterContainer.new()
	center_vbox.add_child(cover_center)

	var cover_wrapper: Control = Control.new()
	cover_wrapper.custom_minimum_size = Vector2(280, 280)
	cover_center.add_child(cover_wrapper)

	halo_glow_rect = ColorRect.new()
	halo_glow_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	halo_glow_rect.offset_left = -20
	halo_glow_rect.offset_top = -20
	halo_glow_rect.offset_right = 20
	halo_glow_rect.offset_bottom = 20
	halo_glow_rect.color = Color(0.95, 0.75, 0.35, 0.15)
	halo_glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cover_wrapper.add_child(halo_glow_rect)

	cover_panel = PanelContainer.new()
	cover_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cov_sb: StyleBoxFlat = StyleBoxFlat.new()
	cov_sb.bg_color = Color(0.12, 0.14, 0.18)
	cov_sb.border_color = Color(0.85, 0.70, 0.35, 0.8)
	cov_sb.set_border_width_all(2)
	cov_sb.set_corner_radius_all(16)
	cov_sb.shadow_color = Color(0, 0, 0, 0.6)
	cov_sb.shadow_size = 16
	cover_panel.add_theme_stylebox_override("panel", cov_sb)
	cover_wrapper.add_child(cover_panel)

	cover_rect = TextureRect.new()
	cover_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cover_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cover_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cover_panel.add_child(cover_rect)

	# Soundscape Labels
	lbl_title = Label.new()
	lbl_title.text = "No Soundscape Loaded"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 22)
	lbl_title.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	center_vbox.add_child(lbl_title)

	lbl_meta = Label.new()
	lbl_meta.text = "Select a soundscape from the library to begin"
	lbl_meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_meta.add_theme_font_size_override("font_size", 12)
	lbl_meta.add_theme_color_override("font_color", Color(0.65, 0.68, 0.75))
	center_vbox.add_child(lbl_meta)

	# 3. Transport Playback Controls
	var transport_panel: PanelContainer = PanelContainer.new()
	var trans_sb: StyleBoxFlat = StyleBoxFlat.new()
	trans_sb.bg_color = Color(0.08, 0.09, 0.12, 0.95)
	trans_sb.border_width_top = 1
	trans_sb.border_color = Color(0.18, 0.20, 0.25, 0.5)
	trans_sb.content_margin_left = 24
	trans_sb.content_margin_right = 24
	trans_sb.content_margin_top = 12
	trans_sb.content_margin_bottom = 12
	transport_panel.add_theme_stylebox_override("panel", trans_sb)
	main_vbox.add_child(transport_panel)

	var trans_vbox: VBoxContainer = VBoxContainer.new()
	trans_vbox.add_theme_constant_override("separation", 10)
	transport_panel.add_child(trans_vbox)

	# Row 1: Buttons
	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 18)
	trans_vbox.add_child(btn_row)

	btn_prev = Button.new()
	btn_prev.icon = load("res://assets/icons/skip_back.svg")
	btn_prev.custom_minimum_size = Vector2(40, 40)
	btn_prev.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_prev.pressed.connect(_on_prev_pressed)
	btn_row.add_child(btn_prev)

	btn_play_pause = Button.new()
	btn_play_pause.icon = load("res://assets/icons/play.svg")
	btn_play_pause.custom_minimum_size = Vector2(60, 60)
	btn_play_pause.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_play_pause.pressed.connect(_on_play_pause_pressed)
	btn_row.add_child(btn_play_pause)

	btn_next = Button.new()
	btn_next.icon = load("res://assets/icons/skip_forward.svg")
	btn_next.custom_minimum_size = Vector2(40, 40)
	btn_next.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_next.pressed.connect(_on_next_pressed)
	btn_row.add_child(btn_next)

	btn_loop = Button.new()
	btn_loop.icon = load("res://assets/icons/loop.svg")
	btn_loop.toggle_mode = true
	btn_loop.button_pressed = true
	btn_loop.custom_minimum_size = Vector2(36, 36)
	btn_loop.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_row.add_child(btn_loop)

	# Row 2: Master Volume
	var vol_row: HBoxContainer = HBoxContainer.new()
	vol_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vol_row.add_theme_constant_override("separation", 12)
	trans_vbox.add_child(vol_row)

	btn_mute = Button.new()
	btn_mute.icon = load("res://assets/icons/volume.svg")
	btn_mute.custom_minimum_size = Vector2(28, 28)
	btn_mute.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_mute.pressed.connect(_toggle_mute)
	vol_row.add_child(btn_mute)

	slider_master_vol = HSlider.new()
	slider_master_vol.min_value = 0.0
	slider_master_vol.max_value = 1.0
	slider_master_vol.step = 0.01
	slider_master_vol.value = 0.85
	slider_master_vol.custom_minimum_size = Vector2(240, 20)
	slider_master_vol.value_changed.connect(_on_master_vol_changed)
	vol_row.add_child(slider_master_vol)

	# 4. Atmosphere Stem Mixer Drawer (Collapsible)
	mixer_drawer = PanelContainer.new()
	var mix_sb: StyleBoxFlat = StyleBoxFlat.new()
	mix_sb.bg_color = Color(0.07, 0.08, 0.10, 0.98)
	mix_sb.border_width_top = 1
	mix_sb.border_color = Color(0.2, 0.22, 0.28, 0.6)
	mix_sb.content_margin_left = 16
	mix_sb.content_margin_right = 16
	mix_sb.content_margin_top = 8
	mix_sb.content_margin_bottom = 8
	mixer_drawer.add_theme_stylebox_override("panel", mix_sb)
	main_vbox.add_child(mixer_drawer)

	var drawer_vbox: VBoxContainer = VBoxContainer.new()
	drawer_vbox.add_theme_constant_override("separation", 6)
	mixer_drawer.add_child(drawer_vbox)

	btn_toggle_mixer = Button.new()
	btn_toggle_mixer.text = "Atmosphere Stem Mixer (Click to Expand)"
	btn_toggle_mixer.icon = load("res://assets/icons/stems.svg")
	btn_toggle_mixer.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_toggle_mixer.add_theme_font_size_override("font_size", 11)
	btn_toggle_mixer.pressed.connect(_toggle_stem_mixer)
	drawer_vbox.add_child(btn_toggle_mixer)

	scroll_stems = ScrollContainer.new()
	scroll_stems.custom_minimum_size = Vector2(0, 110)
	scroll_stems.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_stems.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_stems.visible = false
	drawer_vbox.add_child(scroll_stems)

	stems_container = HBoxContainer.new()
	stems_container.add_theme_constant_override("separation", 10)
	scroll_stems.add_child(stems_container)

	# 5. Overlays (Library, Sleep Timer, Settings)
	_build_library_overlay()
	_build_sleep_timer_overlay()
	_build_settings_overlay()

	# 6. File Picker for .3dscape import
	package_file_dialog = FileDialog.new()
	package_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	package_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	package_file_dialog.filters = PackedStringArray(["*.3dscape, *.zip ; 3D Soundscape Packages (*.3dscape, *.zip)"])
	package_file_dialog.file_selected.connect(_on_package_file_selected)
	add_child(package_file_dialog)

func _build_library_overlay() -> void:
	library_overlay = PanelContainer.new()
	library_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.08, 0.96)
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	library_overlay.add_theme_stylebox_override("panel", sb)
	library_overlay.visible = false
	add_child(library_overlay)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	library_overlay.add_child(vbox)

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	vbox.add_child(top_row)

	var title: Label = Label.new()
	title.text = "Soundscape Library"
	title.add_theme_font_size_override("font_size", 16)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(title)

	var btn_import: Button = Button.new()
	btn_import.text = "Import .3dscape"
	btn_import.icon = load("res://assets/icons/package.svg")
	btn_import.custom_minimum_size = Vector2(140, 32)
	btn_import.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_import.pressed.connect(func(): package_file_dialog.popup_centered(Vector2i(680, 480)))
	top_row.add_child(btn_import)

	var btn_close: Button = Button.new()
	btn_close.text = "✕"
	btn_close.custom_minimum_size = Vector2(32, 32)
	btn_close.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close.pressed.connect(func(): library_overlay.visible = false)
	top_row.add_child(btn_close)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var grid: GridContainer = GridContainer.new()
	grid.name = "LibraryGrid"
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	scroll.add_child(grid)

func _build_sleep_timer_overlay() -> void:
	sleep_overlay = PanelContainer.new()
	sleep_overlay.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	sleep_overlay.custom_minimum_size = Vector2(340, 280)
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.09, 0.12, 0.98)
	sb.border_color = Color(0.85, 0.70, 0.35, 0.8)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	sleep_overlay.add_theme_stylebox_override("panel", sb)
	sleep_overlay.visible = false
	add_child(sleep_overlay)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	sleep_overlay.add_child(vbox)

	var top_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(top_row)

	var title: Label = Label.new()
	title.text = "Sleep Timer"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 14)
	top_row.add_child(title)

	var btn_close: Button = Button.new()
	btn_close.text = "✕"
	btn_close.custom_minimum_size = Vector2(24, 24)
	btn_close.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close.pressed.connect(func(): sleep_overlay.visible = false)
	top_row.add_child(btn_close)

	var durations: Array[Dictionary] = [
		{"name": "Off", "min": 0},
		{"name": "15 Minutes", "min": 15},
		{"name": "30 Minutes", "min": 30},
		{"name": "45 Minutes", "min": 45},
		{"name": "1 Hour", "min": 60},
		{"name": "2 Hours", "min": 120},
	]

	for d in durations:
		var btn: Button = Button.new()
		btn.text = d["name"]
		btn.custom_minimum_size = Vector2(0, 30)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(func(): _set_sleep_timer(d["min"]))
		vbox.add_child(btn)

func _build_settings_overlay() -> void:
	settings_overlay = PanelContainer.new()
	settings_overlay.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	settings_overlay.custom_minimum_size = Vector2(360, 320)
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.09, 0.12, 0.98)
	sb.border_color = Color(0.85, 0.70, 0.35, 0.8)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	settings_overlay.add_theme_stylebox_override("panel", sb)
	settings_overlay.visible = false
	add_child(settings_overlay)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	settings_overlay.add_child(vbox)

	var top_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(top_row)

	var title: Label = Label.new()
	title.text = "Player Settings"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 14)
	top_row.add_child(title)

	var btn_close: Button = Button.new()
	btn_close.text = "✕"
	btn_close.custom_minimum_size = Vector2(24, 24)
	btn_close.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close.pressed.connect(func(): settings_overlay.visible = false)
	top_row.add_child(btn_close)

	var lbl_theme: Label = Label.new()
	lbl_theme.text = "Theme Palette:"
	lbl_theme.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_theme)

	var opt_theme: OptionButton = OptionButton.new()
	opt_theme.add_item("Organic Zen", ThemeManager.ThemeMode.ZEN)
	opt_theme.add_item("Dark Slate", ThemeManager.ThemeMode.DARK)
	opt_theme.add_item("Light Paper", ThemeManager.ThemeMode.LIGHT)
	opt_theme.add_item("Cyberpunk Neon", ThemeManager.ThemeMode.CYBERPUNK)
	opt_theme.select(ThemeManager.current_theme)
	opt_theme.item_selected.connect(func(idx: int):
		ThemeManager.current_theme = opt_theme.get_item_id(idx) as ThemeManager.ThemeMode
		_apply_theme()
	)
	vbox.add_child(opt_theme)

	var lbl_layout: Label = Label.new()
	lbl_layout.text = "Spatial Audio Mode:"
	lbl_layout.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_layout)

	var opt_layout: OptionButton = OptionButton.new()
	opt_layout.add_item("Binaural 3D (Headphones)", SpeakerLayouts.LayoutType.BINAURAL_SOFA)
	opt_layout.add_item("Stereo Panning (Speakers)", SpeakerLayouts.LayoutType.STEREO)
	opt_layout.item_selected.connect(func(idx: int):
		if spatial_engine:
			spatial_engine.speaker_layout = opt_layout.get_item_id(idx) as SpeakerLayouts.LayoutType
	)
	vbox.add_child(opt_layout)

func _apply_theme() -> void:
	var pal: Dictionary = ThemeManager.get_palette()
	if cover_panel:
		var sb: StyleBoxFlat = cover_panel.get_theme_stylebox("panel") as StyleBoxFlat
		if sb:
			sb.border_color = pal["primary"]
	if btn_play_pause:
		btn_play_pause.modulate = pal["primary"]

func refresh_library() -> void:
	soundscape_list = LibraryManager.get_all_soundscapes()
	var grid: GridContainer = library_overlay.find_child("LibraryGrid", true, false) as GridContainer
	if grid == null: return

	for c in grid.get_children():
		c.queue_free()

	for i in range(soundscape_list.size()):
		var item: Dictionary = soundscape_list[i]
		var card: PanelContainer = PanelContainer.new()
		var sb: StyleBoxFlat = StyleBoxFlat.new()
		sb.bg_color = Color(0.1, 0.12, 0.16)
		sb.set_border_width_all(1)
		sb.border_color = Color(0.2, 0.25, 0.35)
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		card.add_theme_stylebox_override("panel", sb)

		var card_vbox: VBoxContainer = VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 6)
		card.add_child(card_vbox)

		var card_img: TextureRect = TextureRect.new()
		card_img.custom_minimum_size = Vector2(160, 110)
		card_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var cov_tex: Texture2D = LibraryManager.load_soundscape_cover_texture(item.get("cover_path", ""))
		if cov_tex:
			card_img.texture = cov_tex
		card_vbox.add_child(card_img)

		var c_title: Label = Label.new()
		c_title.text = item.get("title", "Untitled")
		c_title.add_theme_font_size_override("font_size", 12)
		card_vbox.add_child(c_title)

		var btn_play_item: Button = Button.new()
		btn_play_item.text = "Play Soundscape"
		btn_play_item.icon = load("res://assets/icons/play.svg")
		btn_play_item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_play_item.add_theme_font_size_override("font_size", 10)
		btn_play_item.pressed.connect(func():
			load_soundscape_by_index(i)
			library_overlay.visible = false
			spatial_engine.start_playback()
			if lighting_engine:
				lighting_engine.start_playback()
		)
		card_vbox.add_child(btn_play_item)

		grid.add_child(card)

func load_soundscape_by_index(idx: int) -> void:
	if idx < 0 or idx >= soundscape_list.size():
		return

	current_soundscape_idx = idx
	var item: Dictionary = soundscape_list[idx]
	var p_path: String = item.get("project_path", item.get("folder_path", ""))
	var proj: SoundscapeData.SoundscapeProject = LibraryManager.load_soundscape(p_path)
	if proj:
		load_project(proj, item)

func load_project(proj: SoundscapeData.SoundscapeProject, meta_item: Dictionary = {}) -> void:
	current_project = proj

	# Update Titles
	lbl_title.text = current_project.title
	lbl_meta.text = "%s  •  By %s  •  %d Stems" % [current_project.category, current_project.author, current_project.tracks.size()]

	# Update Cover Texture
	var cov_tex: Texture2D = null
	if not current_project.cover_image_path.is_empty():
		cov_tex = LibraryManager.load_soundscape_cover_texture(current_project.cover_image_path)
	if cov_tex == null and meta_item.has("cover_path"):
		cov_tex = LibraryManager.load_soundscape_cover_texture(meta_item["cover_path"])
	cover_rect.texture = cov_tex

	# Load in Audio Engine
	spatial_engine.load_project(current_project)
	spatial_engine.set_master_volume(slider_master_vol.value)

	# Load in Lighting Engine
	if lighting_engine and current_project.lighting:
		lighting_engine.set_project_lighting(current_project.lighting)

	_rebuild_stem_mixer()

func _rebuild_stem_mixer() -> void:
	if stems_container == null or current_project == null:
		return

	for c in stems_container.get_children():
		c.queue_free()

	btn_toggle_mixer.text = "Atmosphere Stem Mixer (%d Stems — Click to %s)" % [
		current_project.tracks.size(),
		"Collapse" if mixer_expanded else "Expand"
	]

	for track in current_project.tracks:
		var stem_card: PanelContainer = PanelContainer.new()
		var sb: StyleBoxFlat = StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.14, 0.18)
		sb.set_border_width_all(1)
		sb.border_color = Color(0.25, 0.28, 0.35)
		sb.set_corner_radius_all(6)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 8
		sb.content_margin_bottom = 8
		stem_card.add_theme_stylebox_override("panel", sb)

		var v: VBoxContainer = VBoxContainer.new()
		v.alignment = BoxContainer.ALIGNMENT_CENTER
		v.add_theme_constant_override("separation", 6)
		stem_card.add_child(v)

		var icon: TextureRect = TextureRect.new()
		icon.custom_minimum_size = Vector2(24, 24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = ThemeManager.get_sound_icon(track.icon_name)
		v.add_child(icon)

		var s_lbl: Label = Label.new()
		s_lbl.text = track.name
		s_lbl.add_theme_font_size_override("font_size", 10)
		s_lbl.custom_minimum_size = Vector2(100, 0)
		s_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		s_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(s_lbl)

		var s_slider: HSlider = HSlider.new()
		s_slider.min_value = 0.0
		s_slider.max_value = 1.0
		s_slider.step = 0.01
		s_slider.value = track.volume
		s_slider.custom_minimum_size = Vector2(100, 16)
		s_slider.value_changed.connect(func(val: float):
			track.volume = val
			spatial_engine.update_track_volume(track)
		)
		v.add_child(s_slider)

		stems_container.add_child(stem_card)

func _toggle_stem_mixer() -> void:
	mixer_expanded = not mixer_expanded
	if scroll_stems:
		scroll_stems.visible = mixer_expanded
	btn_toggle_mixer.text = "Atmosphere Stem Mixer (%d Stems — Click to %s)" % [
		current_project.tracks.size() if current_project else 0,
		"Collapse" if mixer_expanded else "Expand"
	]

func _on_play_pause_pressed() -> void:
	if spatial_engine.is_playing:
		spatial_engine.stop_playback()
		if lighting_engine:
			lighting_engine.stop_playback()
	else:
		spatial_engine.start_playback()
		if lighting_engine:
			lighting_engine.start_playback()

func _on_playback_state_changed(playing: bool) -> void:
	if btn_play_pause:
		btn_play_pause.icon = load("res://assets/icons/pause.svg") if playing else load("res://assets/icons/play.svg")

func _on_prev_pressed() -> void:
	if soundscape_list.is_empty(): return
	var prev_i: int = (current_soundscape_idx - 1 + soundscape_list.size()) % soundscape_list.size()
	load_soundscape_by_index(prev_i)
	spatial_engine.start_playback()
	if lighting_engine: lighting_engine.start_playback()

func _on_next_pressed() -> void:
	if soundscape_list.is_empty(): return
	var next_i: int = (current_soundscape_idx + 1) % soundscape_list.size()
	load_soundscape_by_index(next_i)
	spatial_engine.start_playback()
	if lighting_engine: lighting_engine.start_playback()

func _on_master_vol_changed(val: float) -> void:
	if spatial_engine:
		spatial_engine.set_master_volume(val)
	if btn_mute:
		btn_mute.icon = load("res://assets/icons/volume_mute.svg") if val <= 0.001 else load("res://assets/icons/volume.svg")

func _toggle_mute() -> void:
	if slider_master_vol.value > 0:
		slider_master_vol.value = 0.0
	else:
		slider_master_vol.value = 0.85

func _toggle_smart_lighting() -> void:
	if current_project and current_project.lighting:
		current_project.lighting.enabled = not current_project.lighting.enabled
		btn_light_toggle.modulate = Color(0.2, 1.0, 0.4) if current_project.lighting.enabled else Color(1, 1, 1)
		if lighting_engine:
			lighting_engine.set_project_lighting(current_project.lighting)
			if spatial_engine.is_playing and current_project.lighting.enabled:
				lighting_engine.start_playback()
			elif not current_project.lighting.enabled:
				lighting_engine.stop_playback()

func _on_track_triggered(track_id: String) -> void:
	if lighting_engine:
		lighting_engine.on_sound_triggered(track_id)

func _set_sleep_timer(minutes: int) -> void:
	sleep_overlay.visible = false
	if minutes <= 0:
		sleep_timer_active = false
		fade_out_active = false
		sleep_timer_total_sec = 0.0
		sleep_timer_remaining_sec = 0.0
	else:
		sleep_timer_total_sec = float(minutes * 60)
		sleep_timer_remaining_sec = sleep_timer_total_sec
		sleep_timer_active = true
		fade_out_active = false
	_update_timer_button_ui()

func _update_timer_button_ui() -> void:
	if not sleep_timer_active:
		btn_sleep_timer.text = " Timer"
		btn_sleep_timer.modulate = Color(1, 1, 1)
	else:
		var mins_left: int = int(ceil(sleep_timer_remaining_sec / 60.0))
		btn_sleep_timer.text = " %dm" % mins_left
		btn_sleep_timer.modulate = Color(0.95, 0.85, 0.4)

func _toggle_library_overlay() -> void:
	library_overlay.visible = not library_overlay.visible

func _toggle_sleep_overlay() -> void:
	sleep_overlay.visible = not sleep_overlay.visible

func _toggle_settings_overlay() -> void:
	settings_overlay.visible = not settings_overlay.visible

func _on_package_file_selected(path: String) -> void:
	var imported_proj: SoundscapeData.SoundscapeProject = LibraryManager.import_soundscape_package(path)
	if imported_proj:
		refresh_library()
		load_project(imported_proj)
		spatial_engine.start_playback()
		if lighting_engine: lighting_engine.start_playback()
