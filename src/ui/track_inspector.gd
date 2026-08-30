class_name TrackInspector
extends VBoxContainer

# Author: Adromir
# Repository: https://github.com/adromir

signal track_modified(track_id: String)
signal rate_picker_requested(track_id: String)
signal track_reset_requested(track_id: String)
signal all_tracks_reset_requested()

var current_track: SoundscapeData.TrackConfig = null

const PRESET_COLORS: Array[String] = [
	"#00e5ff", # Neon Cyan
	"#00e676", # Emerald Green
	"#ff9100", # Amber Flame
	"#ff1744", # Crimson Red
	"#d500f9", # Neon Violet
	"#2979ff", # Royal Azure
	"#ffd600", # Radiant Gold
	"#f50057"  # Electric Rose
]

const PRESET_ICONS: Array[String] = [
	"volume", "fire", "water", "birds", "wind", "rain", "bell", "steps", "music", "fx", "voice"
]

const ICON_LABELS: Dictionary = {
	"volume": "Default / Volume",
	"fire": "Fire / Flame",
	"water": "Water / Stream",
	"birds": "Birds / Wildlife",
	"wind": "Wind / Breeze",
	"rain": "Rain / Storm",
	"bell": "Bell / Chime",
	"steps": "Footsteps",
	"music": "Music / Melody",
	"fx": "Sound FX",
	"voice": "Voice / Speech"
}

@onready var empty_state_label: Label = $EmptyStateLabel
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var content_container: VBoxContainer = $ScrollContainer/Content
@onready var btn_reset_track: Button = $ScrollContainer/Content/ToolbarHBox/BtnResetTrack
@onready var name_edit: LineEdit = $ScrollContainer/Content/NameEdit

# Audio Source
@onready var audio_path_label: Label = $ScrollContainer/Content/AudioSourceGroup/AudioHBox/AudioPathLabel
@onready var btn_load_audio: Button = $ScrollContainer/Content/AudioSourceGroup/AudioHBox/BtnLoadAudio

@onready var color_hbox: HBoxContainer = $ScrollContainer/Content/AppearanceGroup/ColorHBox
@onready var icon_option_button: OptionButton = $ScrollContainer/Content/AppearanceGroup/IconOptionButton

# Routing
@onready var routing_option: OptionButton = $ScrollContainer/Content/RoutingOption

# Multi-Channel Group
@onready var multi_channel_group: VBoxContainer = $ScrollContainer/Content/MultiChannelGroup
@onready var channels_grid: HFlowContainer = $ScrollContainer/Content/MultiChannelGroup/ChannelsGrid
@onready var btn_stereo: Button = $ScrollContainer/Content/MultiChannelGroup/PresetsHBox/BtnStereo
@onready var btn_surround: Button = $ScrollContainer/Content/MultiChannelGroup/PresetsHBox/BtnSurround
@onready var btn_clear_ch: Button = $ScrollContainer/Content/MultiChannelGroup/PresetsHBox/BtnClearCh

# Omnipresent Group
@onready var omnipresent_group: PanelContainer = $ScrollContainer/Content/OmnipresentGroup

# Spatial Group
@onready var spatial_group: VBoxContainer = $ScrollContainer/Content/SpatialGroup
@onready var azimuth_slider: HSlider = $ScrollContainer/Content/SpatialGroup/AzimuthSlider
@onready var azimuth_val_label: Label = $ScrollContainer/Content/SpatialGroup/AzimuthHBox/AzimuthValLabel
@onready var elevation_slider: HSlider = $ScrollContainer/Content/SpatialGroup/ElevationSlider
@onready var elevation_val_label: Label = $ScrollContainer/Content/SpatialGroup/ElevationHBox/ElevationValLabel
@onready var distance_slider: HSlider = $ScrollContainer/Content/SpatialGroup/DistanceSlider
@onready var distance_val_label: Label = $ScrollContainer/Content/SpatialGroup/DistanceHBox/DistanceValLabel

# Movement Group
@onready var movement_group: VBoxContainer = $ScrollContainer/Content/MovementGroup
@onready var mov_pattern_option: OptionButton = $ScrollContainer/Content/MovementGroup/PatternOption
@onready var mov_timing_option: OptionButton = $ScrollContainer/Content/MovementGroup/TimingOption
@onready var mov_speed_val_label: Label = $ScrollContainer/Content/MovementGroup/SpeedHBox/SpeedValLabel
@onready var mov_speed_slider: HSlider = $ScrollContainer/Content/MovementGroup/SpeedSlider
@onready var roam_group: VBoxContainer = $ScrollContainer/Content/MovementGroup/RoamGroup
@onready var roam_dist_slider: HSlider = $ScrollContainer/Content/MovementGroup/RoamGroup/RoamDistSlider
@onready var roam_dist_val_label: Label = $ScrollContainer/Content/MovementGroup/RoamGroup/RoamDistHBox/RoamDistValLabel

# Trigger Group
@onready var trigger_group: VBoxContainer = $ScrollContainer/Content/TriggerGroup
@onready var trigger_mode_option: OptionButton = $ScrollContainer/Content/TriggerGroup/TriggerModeOption
@onready var check_crossfade: CheckButton = $ScrollContainer/Content/TriggerGroup/CheckCrossfade
@onready var btn_open_rate_picker: Button = $ScrollContainer/Content/TriggerGroup/BtnOpenRatePicker
@onready var rate_summary_label: Label = $ScrollContainer/Content/TriggerGroup/RateSummaryLabel
@onready var preset_container: HFlowContainer = $ScrollContainer/Content/TriggerGroup/PresetContainer

@onready var fixed_group: VBoxContainer = $ScrollContainer/Content/TriggerGroup/FixedGroup
@onready var interval_slider: HSlider = $ScrollContainer/Content/TriggerGroup/FixedGroup/IntervalSlider
@onready var interval_val_label: Label = $ScrollContainer/Content/TriggerGroup/FixedGroup/IntervalHBox/IntervalValLabel

@onready var density_group: VBoxContainer = $ScrollContainer/Content/TriggerGroup/DensityGroup
@onready var density_count_slider: HSlider = $ScrollContainer/Content/TriggerGroup/DensityGroup/DensityCountSlider
@onready var density_count_val_label: Label = $ScrollContainer/Content/TriggerGroup/DensityGroup/DensityCountHBox/DensityCountValLabel
@onready var density_window_slider: HSlider = $ScrollContainer/Content/TriggerGroup/DensityGroup/DensityWindowSlider
@onready var density_window_val_label: Label = $ScrollContainer/Content/TriggerGroup/DensityGroup/DensityWindowHBox/DensityWindowValLabel

@onready var cooldown_group: VBoxContainer = $ScrollContainer/Content/TriggerGroup/CooldownGroup
@onready var cooldown_slider: HSlider = $ScrollContainer/Content/TriggerGroup/CooldownGroup/CooldownSlider
@onready var cooldown_val_label: Label = $ScrollContainer/Content/TriggerGroup/CooldownGroup/CooldownHBox/CooldownValLabel

const RATE_PRESETS: Array[Dictionary] = [
	{"label": "1x /1m", "count": 1, "window": 60.0},
	{"label": "2x /1m", "count": 2, "window": 60.0},
	{"label": "1x /5m", "count": 1, "window": 300.0},
	{"label": "1x /10m", "count": 1, "window": 600.0},
	{"label": "5x /10m", "count": 5, "window": 600.0},
	{"label": "1x /1h", "count": 1, "window": 3600.0},
	{"label": "Custom", "count": -1, "window": -1.0}
]

var _color_buttons: Array[Button] = []
var _preset_buttons: Array[Button] = []
var _audio_file_dialog: FileDialog = null
var _is_custom_density_open: bool = false

func _ready() -> void:
	_setup_file_dialog()
	_setup_appearance_palettes()
	_setup_rate_presets()
	_connect_controls()
	update_localization()

func _setup_file_dialog() -> void:
	if _audio_file_dialog == null:
		_audio_file_dialog = FileDialog.new()
		_audio_file_dialog.name = "TrackAudioFileDialog"
		_audio_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		_audio_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		_audio_file_dialog.use_native_dialog = false
		_audio_file_dialog.filters = PackedStringArray([
			"*.mp3, *.ogg, *.wav ; Supported Audio Files (*.mp3, *.ogg, *.wav)",
			"*.mp3 ; MP3 Audio (*.mp3)",
			"*.ogg ; OGG Vorbis (*.ogg)",
			"*.wav ; WAV Audio (*.wav)",
			"*.* ; All Files (*.*)"
		])
		_audio_file_dialog.file_selected.connect(_on_audio_file_selected)
		add_child(_audio_file_dialog)

	if btn_load_audio:
		btn_load_audio.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_load_audio.pressed.connect(func():
			if _audio_file_dialog:
				ThemeManager.apply_theme(_audio_file_dialog, ThemeManager.current_theme)
				_audio_file_dialog.popup_centered(Vector2i(800, 500))
		)

func _setup_rate_presets() -> void:
	if preset_container == null:
		return

	for child in preset_container.get_children():
		child.queue_free()
	_preset_buttons.clear()

	for preset in RATE_PRESETS:
		var btn: Button = Button.new()
		btn.text = preset["label"]
		btn.custom_minimum_size = Vector2(58, 24)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_font_size_override("font_size", 10)
		
		var p_count: int = preset["count"]
		var p_win: float = preset["window"]
		
		btn.pressed.connect(func():
			if current_track == null:
				return
			if p_count == -1:
				_is_custom_density_open = true
				_update_visibility_groups()
			else:
				_is_custom_density_open = false
				current_track.trigger.apply_preset(p_count, p_win)
				if interval_slider: interval_slider.value = current_track.trigger.fixed_interval_sec
				if density_count_slider: density_count_slider.value = float(current_track.trigger.density_count)
				if density_window_slider: density_window_slider.value = current_track.trigger.density_window_sec
				_update_visibility_groups()
				_update_preset_selection()
				track_modified.emit(current_track.id)
		)
		preset_container.add_child(btn)
		_preset_buttons.append(btn)

func _on_audio_file_selected(path: String) -> void:
	if current_track == null:
		return
	current_track.file_path = path
	if current_track.name.begins_with("Stem") or current_track.name.is_empty():
		var clean_name: String = path.get_file().get_basename().replace("_", " ").capitalize()
		current_track.name = clean_name
		if name_edit: name_edit.text = clean_name
	if audio_path_label:
		audio_path_label.text = path.get_file()
		audio_path_label.tooltip_text = path
	track_modified.emit(current_track.id)

func _update_preset_selection() -> void:
	if current_track == null:
		return
	var cur_count: int = current_track.trigger.density_count
	var cur_win: float = current_track.trigger.density_window_sec
	
	for i in range(_preset_buttons.size()):
		var btn: Button = _preset_buttons[i]
		var preset: Dictionary = RATE_PRESETS[i]
		var is_match: bool = false
		
		if preset["count"] == -1:
			is_match = _is_custom_density_open
		else:
			is_match = (cur_count == preset["count"] and is_equal_approx(cur_win, preset["window"]))
			
		if is_match:
			btn.modulate = Color(1.3, 1.3, 1.3)
			btn.add_theme_color_override("font_color", Color(0.2, 0.95, 0.6))
		else:
			btn.modulate = Color(0.75, 0.75, 0.75)
			btn.remove_theme_color_override("font_color")

func _setup_appearance_palettes() -> void:
	if color_hbox:
		for c_hex in PRESET_COLORS:
			var btn: Button = Button.new()
			btn.custom_minimum_size = Vector2(22, 22)
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			btn.flat = true
			var col: Color = Color.from_string(c_hex, Color.CYAN)
			
			var rect: ColorRect = ColorRect.new()
			rect.color = col
			rect.custom_minimum_size = Vector2(16, 16)
			rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.add_child(rect)
			
			btn.pressed.connect(func():
				if current_track:
					current_track.color_hex = c_hex
					_update_color_selection()
					track_modified.emit(current_track.id)
			)
			color_hbox.add_child(btn)
			_color_buttons.append(btn)

	if icon_option_button:
		icon_option_button.clear()
		for i in range(PRESET_ICONS.size()):
			var icon_name: String = PRESET_ICONS[i]
			var label: String = ICON_LABELS.get(icon_name, icon_name.capitalize())
			var icon_res: Texture2D = ThemeManager.get_sound_icon(icon_name)
			icon_option_button.add_icon_item(icon_res, label, i)
		icon_option_button.item_selected.connect(func(idx: int):
			if current_track and idx >= 0 and idx < PRESET_ICONS.size():
				current_track.icon_name = PRESET_ICONS[idx]
				_update_icon_selection()
				track_modified.emit(current_track.id)
		)

func _update_color_selection() -> void:
	if current_track == null:
		return
	for i in range(_color_buttons.size()):
		var btn: Button = _color_buttons[i]
		var c_hex: String = PRESET_COLORS[i]
		if current_track.color_hex == c_hex:
			btn.modulate = Color(1.3, 1.3, 1.3)
		else:
			btn.modulate = Color(0.7, 0.7, 0.7)

func _update_icon_selection() -> void:
	if current_track == null:
		return
	var active_idx: int = PRESET_ICONS.find(current_track.icon_name)
	if icon_option_button and active_idx >= 0:
		icon_option_button.selected = active_idx

func _connect_controls() -> void:
	if btn_reset_track:
		btn_reset_track.icon = load("res://assets/icons/reset.svg")
		btn_reset_track.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_reset_track.pressed.connect(func():
			if current_track:
				track_reset_requested.emit(current_track.id)
		)

	if check_crossfade:
		check_crossfade.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		check_crossfade.toggled.connect(func(toggled: bool):
			if current_track:
				current_track.crossfade = toggled
				track_modified.emit(current_track.id)
		)

	if routing_option:
		routing_option.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		routing_option.item_selected.connect(_on_routing_changed)

	if mov_pattern_option:
		mov_pattern_option.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		mov_pattern_option.item_selected.connect(_on_movement_pattern_changed)

	if mov_timing_option:
		mov_timing_option.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		mov_timing_option.item_selected.connect(_on_movement_timing_changed)

	if trigger_mode_option:
		trigger_mode_option.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		trigger_mode_option.item_selected.connect(_on_trigger_mode_changed)

	if btn_open_rate_picker:
		btn_open_rate_picker.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_open_rate_picker.pressed.connect(func():
			if current_track:
				rate_picker_requested.emit(current_track.id)
		)

	if btn_stereo:
		btn_stereo.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_stereo.pressed.connect(func():
			if current_track:
				current_track.target_channels = ["FL", "FR"]
				_update_channels_grid()
				track_modified.emit(current_track.id)
		)

	if btn_surround:
		btn_surround.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_surround.pressed.connect(func():
			if current_track:
				current_track.target_channels = ["FL", "FR", "BL", "BR", "FC", "LFE"]
				_update_channels_grid()
				track_modified.emit(current_track.id)
		)

	if btn_clear_ch:
		btn_clear_ch.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_clear_ch.pressed.connect(func():
			if current_track:
				current_track.target_channels = []
				_update_channels_grid()
				track_modified.emit(current_track.id)
		)

	for s in [azimuth_slider, elevation_slider, distance_slider, mov_speed_slider, interval_slider, density_count_slider, density_window_slider, cooldown_slider]:
		if s: s.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if name_edit:
		name_edit.text_changed.connect(func(new_text: String):
			if current_track:
				current_track.name = new_text
				track_modified.emit(current_track.id)
		)

	if azimuth_slider:
		azimuth_slider.value_changed.connect(func(val: float):
			if current_track:
				current_track.azimuth = val
				if azimuth_val_label: azimuth_val_label.text = "%.1f°" % val
				track_modified.emit(current_track.id)
		)

	if elevation_slider:
		elevation_slider.value_changed.connect(func(val: float):
			if current_track:
				current_track.elevation = val
				if elevation_val_label: elevation_val_label.text = "%.1f°" % val
				track_modified.emit(current_track.id)
		)

	if distance_slider:
		distance_slider.value_changed.connect(func(val: float):
			if current_track:
				current_track.distance = val
				if distance_val_label: distance_val_label.text = "%.1fm" % val
				track_modified.emit(current_track.id)
		)

	if mov_speed_slider:
		mov_speed_slider.value_changed.connect(func(val: float):
			if current_track:
				current_track.movement.speed = val
				if mov_speed_val_label: mov_speed_val_label.text = "%.1fx (%.1f m/s)" % [val, val * 2.0]
				track_modified.emit(current_track.id)
		)

	if roam_dist_slider:
		roam_dist_slider.value_changed.connect(func(val: float):
			if current_track:
				current_track.movement.max_distance = val
				if roam_dist_val_label: roam_dist_val_label.text = "%.1fm" % val
				track_modified.emit(current_track.id)
		)

	if interval_slider:
		interval_slider.value_changed.connect(func(val: float):
			if current_track:
				current_track.trigger.fixed_interval_sec = val
				if interval_val_label: interval_val_label.text = "%.1fs" % val
				track_modified.emit(current_track.id)
		)

	if density_count_slider:
		density_count_slider.value_changed.connect(func(val: float):
			if current_track:
				current_track.trigger.density_count = int(val)
				if density_count_val_label: density_count_val_label.text = "%dx" % int(val)
				if rate_summary_label: rate_summary_label.text = "⚡ Rate: " + current_track.trigger.get_rate_label()
				_update_preset_selection()
				track_modified.emit(current_track.id)
		)

	if density_window_slider:
		density_window_slider.value_changed.connect(func(val: float):
			if current_track:
				current_track.trigger.density_window_sec = val
				var mins: float = val / 60.0
				if density_window_val_label:
					if val < 60.0:
						density_window_val_label.text = "%ds" % int(val)
					elif val >= 3600.0:
						density_window_val_label.text = "%.1f h" % (val / 3600.0)
					else:
						density_window_val_label.text = "%.1f min" % mins
				if rate_summary_label: rate_summary_label.text = "⚡ Rate: " + current_track.trigger.get_rate_label()
				_update_preset_selection()
				track_modified.emit(current_track.id)
		)

	if cooldown_slider:
		cooldown_slider.value_changed.connect(func(val: float):
			if current_track:
				current_track.trigger.cooldown_sec = val
				if cooldown_val_label: cooldown_val_label.text = "%.1fs" % val
				track_modified.emit(current_track.id)
		)

func _select_option_by_id(opt: OptionButton, target_id: int) -> void:
	if opt == null: return
	for i in range(opt.item_count):
		if opt.get_item_id(i) == target_id:
			opt.select(i)
			return

func update_localization() -> void:
	if routing_option:
		var sel_id: int = routing_option.get_selected_id()
		routing_option.clear()
		routing_option.add_item(LocalizationData.tr_key("MODE_POINT_3D"), SoundscapeData.ChannelRoutingMode.POINT_3D)
		routing_option.add_item(LocalizationData.tr_key("MODE_OMNIPRESENT"), SoundscapeData.ChannelRoutingMode.OMNIPRESENT)
		routing_option.add_item(LocalizationData.tr_key("MODE_MULTI_CH"), SoundscapeData.ChannelRoutingMode.MULTI_CHANNEL)
		if sel_id >= 0:
			_select_option_by_id(routing_option, sel_id)
		routing_option.tooltip_text = LocalizationData.tr_key("TOOLTIP_ROUTING")

	if mov_pattern_option:
		var sel_id: int = mov_pattern_option.get_selected_id()
		mov_pattern_option.clear()
		mov_pattern_option.add_item(LocalizationData.tr_key("MOV_NONE"), SoundscapeData.MovementPattern.NONE)
		mov_pattern_option.add_item(LocalizationData.tr_key("MOV_PING_PONG_LR"), SoundscapeData.MovementPattern.PING_PONG_LR)
		mov_pattern_option.add_item(LocalizationData.tr_key("MOV_ONE_WAY_LR"), SoundscapeData.MovementPattern.ONE_WAY_LR)
		mov_pattern_option.add_item(LocalizationData.tr_key("MOV_PING_PONG_FB"), SoundscapeData.MovementPattern.PING_PONG_FB)
		mov_pattern_option.add_item(LocalizationData.tr_key("MOV_ONE_WAY_FB"), SoundscapeData.MovementPattern.ONE_WAY_FB)
		mov_pattern_option.add_item(LocalizationData.tr_key("MOV_RANDOM_WALK"), SoundscapeData.MovementPattern.RANDOM_WALK)
		if sel_id >= 0:
			_select_option_by_id(mov_pattern_option, sel_id)

	if mov_timing_option:
		var sel_id: int = mov_timing_option.get_selected_id()
		mov_timing_option.clear()
		mov_timing_option.add_item(LocalizationData.tr_key("TIMING_IN_FLIGHT"), SoundscapeData.MovementTiming.CONTINUOUS_IN_FLIGHT)
		mov_timing_option.add_item(LocalizationData.tr_key("TIMING_JUMP"), SoundscapeData.MovementTiming.JUMP_PER_TRIGGER)
		if sel_id >= 0:
			_select_option_by_id(mov_timing_option, sel_id)

	if trigger_mode_option:
		var sel_id: int = trigger_mode_option.get_selected_id()
		trigger_mode_option.clear()
		trigger_mode_option.add_item(LocalizationData.tr_key("TRIG_CONTINUOUS"), SoundscapeData.TriggerMode.CONTINUOUS_LOOP)
		trigger_mode_option.add_item(LocalizationData.tr_key("TRIG_FIXED"), SoundscapeData.TriggerMode.FIXED_INTERVAL)
		trigger_mode_option.add_item(LocalizationData.tr_key("TRIG_RANDOM"), SoundscapeData.TriggerMode.RANDOM_INTERVAL)
		if sel_id >= 0:
			_select_option_by_id(trigger_mode_option, sel_id)

	if btn_load_audio: btn_load_audio.text = LocalizationData.tr_key("BTN_LOAD")
	if btn_reset_track:
		btn_reset_track.text = LocalizationData.tr_key("BTN_RESET_STEM")
		btn_reset_track.tooltip_text = LocalizationData.tr_key("TOOLTIP_RESET_STEM")
	if check_crossfade:
		check_crossfade.text = LocalizationData.tr_key("CROSSFADE_LOOP")
	if density_count_slider: density_count_slider.tooltip_text = LocalizationData.tr_key("TOOLTIP_DENSITY_COUNT")
	if density_window_slider: density_window_slider.tooltip_text = LocalizationData.tr_key("TOOLTIP_DENSITY_WINDOW")
	if cooldown_slider: cooldown_slider.tooltip_text = LocalizationData.tr_key("TOOLTIP_COOLDOWN")

func inspect_track(track: SoundscapeData.TrackConfig) -> void:
	current_track = track
	if current_track == null:
		if empty_state_label: empty_state_label.visible = true
		if scroll_container: scroll_container.visible = false
		return

	if empty_state_label: empty_state_label.visible = false
	if scroll_container: scroll_container.visible = true

	if name_edit: name_edit.text = track.name
	if audio_path_label:
		if not track.file_path.is_empty():
			audio_path_label.text = track.file_path.get_file()
			audio_path_label.tooltip_text = track.file_path
		else:
			audio_path_label.text = "No audio file assigned"
			audio_path_label.tooltip_text = ""

	if routing_option: _select_option_by_id(routing_option, track.channel_mode)
	if azimuth_slider:
		azimuth_slider.set_value_no_signal(track.azimuth)
		if azimuth_val_label: azimuth_val_label.text = "%.1f°" % track.azimuth
	if elevation_slider:
		elevation_slider.set_value_no_signal(track.elevation)
		if elevation_val_label: elevation_val_label.text = "%.1f°" % track.elevation
	if distance_slider:
		distance_slider.set_value_no_signal(track.distance)
		if distance_val_label: distance_val_label.text = "%.1fm" % track.distance

	if mov_pattern_option: _select_option_by_id(mov_pattern_option, track.movement.pattern)
	if mov_timing_option: _select_option_by_id(mov_timing_option, track.movement.timing)
	if mov_speed_slider:
		mov_speed_slider.set_value_no_signal(track.movement.speed)
		if mov_speed_val_label: mov_speed_val_label.text = "%.1fx (%.1f m/s)" % [track.movement.speed, track.movement.speed * 2.0]
	if roam_dist_slider:
		roam_dist_slider.set_value_no_signal(track.movement.max_distance)
		if roam_dist_val_label: roam_dist_val_label.text = "%.1fm" % track.movement.max_distance

	if trigger_mode_option: _select_option_by_id(trigger_mode_option, track.trigger.mode)
	if check_crossfade: check_crossfade.set_pressed_no_signal(track.crossfade)
	if btn_open_rate_picker:
		btn_open_rate_picker.text = "🔀 Frequency: %s  (Change...)" % track.trigger.get_rate_label()
	if rate_summary_label: rate_summary_label.text = "⚡ Rate: " + track.trigger.get_rate_label()

	if interval_slider:
		interval_slider.set_value_no_signal(track.trigger.fixed_interval_sec)
		if interval_val_label: interval_val_label.text = "%.1fs" % track.trigger.fixed_interval_sec
	if density_count_slider:
		density_count_slider.set_value_no_signal(float(track.trigger.density_count))
		if density_count_val_label: density_count_val_label.text = "%dx" % track.trigger.density_count
	if density_window_slider:
		density_window_slider.set_value_no_signal(track.trigger.density_window_sec)
		if density_window_val_label:
			if track.trigger.density_window_sec < 60.0:
				density_window_val_label.text = "%ds" % int(track.trigger.density_window_sec)
			elif track.trigger.density_window_sec >= 3600.0:
				density_window_val_label.text = "%.1f h" % (track.trigger.density_window_sec / 3600.0)
			else:
				density_window_val_label.text = "%.1f min" % (track.trigger.density_window_sec / 60.0)
	if cooldown_slider:
		cooldown_slider.set_value_no_signal(track.trigger.cooldown_sec)
		if cooldown_val_label: cooldown_val_label.text = "%.1fs" % track.trigger.cooldown_sec

	_update_color_selection()
	_update_icon_selection()
	_update_preset_selection()
	_update_channels_grid()
	_update_visibility_groups()

const ALL_CHANNELS: Array[String] = [
	"FL", "FR", "FC", "LFE", "BL", "BR", "SL", "SR", "TFL", "TFR", "TBL", "TBR"
]

func _update_channels_grid() -> void:
	if channels_grid == null or current_track == null:
		return

	for child in channels_grid.get_children():
		child.queue_free()

	var pal: Dictionary = ThemeManager.get_palette()
	for ch in ALL_CHANNELS:
		var btn: Button = Button.new()
		btn.text = ch
		btn.toggle_mode = true
		var is_active: bool = current_track.target_channels.has(ch)
		btn.button_pressed = is_active
		btn.custom_minimum_size = Vector2(46, 26)
		btn.add_theme_font_size_override("font_size", 10)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		if is_active:
			btn.add_theme_color_override("font_color", pal.get("primary", Color.CYAN))

		var cur_ch: String = ch
		btn.toggled.connect(func(toggled: bool):
			if current_track:
				if toggled and not current_track.target_channels.has(cur_ch):
					current_track.target_channels.append(cur_ch)
				elif not toggled and current_track.target_channels.has(cur_ch):
					current_track.target_channels.erase(cur_ch)
				_update_channels_grid()
				track_modified.emit(current_track.id)
		)
		channels_grid.add_child(btn)

func _update_visibility_groups() -> void:
	if current_track == null:
		return

	# Routing visibility
	if spatial_group:
		spatial_group.visible = (current_track.channel_mode == SoundscapeData.ChannelRoutingMode.POINT_3D)
	if movement_group:
		movement_group.visible = (current_track.channel_mode == SoundscapeData.ChannelRoutingMode.POINT_3D)
	if roam_group:
		roam_group.visible = (current_track.channel_mode == SoundscapeData.ChannelRoutingMode.POINT_3D and current_track.movement.pattern == SoundscapeData.MovementPattern.RANDOM_WALK)
	if multi_channel_group:
		multi_channel_group.visible = (current_track.channel_mode == SoundscapeData.ChannelRoutingMode.MULTI_CHANNEL)
	if omnipresent_group:
		omnipresent_group.visible = (current_track.channel_mode == SoundscapeData.ChannelRoutingMode.OMNIPRESENT)

	# Trigger mode visibility
	var trig_mode: SoundscapeData.TriggerMode = current_track.trigger.mode
	if check_crossfade:
		check_crossfade.visible = (trig_mode == SoundscapeData.TriggerMode.CONTINUOUS_LOOP)
	if fixed_group:
		fixed_group.visible = (trig_mode == SoundscapeData.TriggerMode.FIXED_INTERVAL)
	if btn_open_rate_picker:
		btn_open_rate_picker.visible = (trig_mode == SoundscapeData.TriggerMode.RANDOM_INTERVAL)
	if preset_container:
		preset_container.visible = (trig_mode == SoundscapeData.TriggerMode.RANDOM_INTERVAL)
	if rate_summary_label:
		rate_summary_label.visible = false
	if density_group:
		density_group.visible = (trig_mode == SoundscapeData.TriggerMode.RANDOM_INTERVAL and _is_custom_density_open)
	if cooldown_group:
		cooldown_group.visible = (trig_mode != SoundscapeData.TriggerMode.CONTINUOUS_LOOP)

func sync_from_track() -> void:
	if current_track == null:
		return
	if azimuth_slider:
		azimuth_slider.set_value_no_signal(current_track.azimuth)
		if azimuth_val_label: azimuth_val_label.text = "%.1f°" % current_track.azimuth
	if elevation_slider:
		elevation_slider.set_value_no_signal(current_track.elevation)
		if elevation_val_label: elevation_val_label.text = "%.1f°" % current_track.elevation
	if distance_slider:
		distance_slider.set_value_no_signal(current_track.distance)
		if distance_val_label: distance_val_label.text = "%.1fm" % current_track.distance
	if check_crossfade:
		check_crossfade.set_pressed_no_signal(current_track.crossfade)

func _on_routing_changed(index: int) -> void:
	if current_track and routing_option:
		var mode_id: int = routing_option.get_item_id(index)
		current_track.channel_mode = mode_id as SoundscapeData.ChannelRoutingMode
		_update_channels_grid()
		_update_visibility_groups()
		track_modified.emit(current_track.id)

func _on_movement_pattern_changed(index: int) -> void:
	if current_track and mov_pattern_option:
		var pat_id: int = mov_pattern_option.get_item_id(index)
		current_track.movement.pattern = pat_id as SoundscapeData.MovementPattern
		_update_visibility_groups()
		track_modified.emit(current_track.id)

func _on_movement_timing_changed(index: int) -> void:
	if current_track and mov_timing_option:
		var tim_id: int = mov_timing_option.get_item_id(index)
		current_track.movement.timing = tim_id as SoundscapeData.MovementTiming
		track_modified.emit(current_track.id)

func _on_trigger_mode_changed(index: int) -> void:
	if current_track and trigger_mode_option:
		var mode_id: int = trigger_mode_option.get_item_id(index)
		current_track.trigger.mode = mode_id as SoundscapeData.TriggerMode
		_is_custom_density_open = false
		_update_visibility_groups()
		_update_preset_selection()
		track_modified.emit(current_track.id)
