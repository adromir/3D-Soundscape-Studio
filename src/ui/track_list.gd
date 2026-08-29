class_name TrackList
extends VBoxContainer

# Author: Adromir
# Repository: https://github.com/adromir

signal track_selected(track_id: String)
signal track_volume_changed(track_id: String, volume: float)
signal track_mute_toggled(track_id: String, muted: bool)
signal track_solo_toggled(track_id: String, solo: bool)
signal track_deleted(track_id: String)
signal track_trigger_mode_changed(track_id: String)
signal rate_picker_requested(track_id: String)
signal add_track_requested()

var project: SoundscapeData.SoundscapeProject = null
var selected_track_id: String = ""

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var items_container: VBoxContainer = $ScrollContainer/ItemsContainer
@onready var add_button: Button = $AddButton

func _ready() -> void:
	if add_button:
		add_button.icon = load("res://assets/icons/plus.svg")
		add_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		add_button.pressed.connect(func(): add_track_requested.emit())
	update_localization()

func update_localization() -> void:
	if add_button:
		add_button.text = LocalizationData.tr_key("BTN_ADD_TRACK")

func set_project(proj: SoundscapeData.SoundscapeProject) -> void:
	project = proj
	rebuild_list()

func select_track(track_id: String) -> void:
	selected_track_id = track_id
	_highlight_selected()

func rebuild_list() -> void:
	if items_container == null:
		return

	for child in items_container.get_children():
		child.queue_free()

	if project == null or project.tracks.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = LocalizationData.tr_key("EMPTY_TRACKS_DESC")
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", ThemeManager.get_palette()["text_dim"])
		items_container.add_child(empty_lbl)
		return

	for track in project.tracks:
		var item: PanelContainer = _create_track_item(track)
		items_container.add_child(item)

	_highlight_selected()

func _create_track_item(track: SoundscapeData.TrackConfig) -> PanelContainer:
	var pal: Dictionary = ThemeManager.get_palette()
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "TrackItem_" + track.id
	panel.custom_minimum_size = Vector2(0, 30)

	# Hover feedback
	panel.mouse_entered.connect(func():
		if panel.name != ("TrackItem_" + selected_track_id):
			panel.modulate = Color(1.15, 1.25, 1.35)
	)
	panel.mouse_exited.connect(func():
		if panel.name != ("TrackItem_" + selected_track_id):
			panel.modulate = Color(1.0, 1.0, 1.0)
	)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 3)
	panel.add_child(hbox)

	# Left status strip (custom track color)
	var track_col: Color = Color.from_string(track.color_hex, pal["primary"])
	var indicator: ColorRect = ColorRect.new()
	indicator.custom_minimum_size = Vector2(3, 18)
	indicator.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	indicator.color = track_col if not track.muted else pal["text_dim"]
	indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(indicator)

	# Sound Icon (theme-aware, vibrant high contrast)
	var icon_rect: TextureRect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(18, 18)
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_rect.texture = ThemeManager.get_sound_icon(track.icon_name)
	if ThemeManager.is_dark_mode():
		icon_rect.modulate = track_col if not track.muted else pal["text_dim"]
	else:
		icon_rect.modulate = track_col.darkened(0.2) if not track.muted else pal["text_dim"]
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(icon_rect)

	# Select Button with Track Name
	var btn_select: Button = Button.new()
	btn_select.text = track.name
	btn_select.flat = true
	btn_select.clip_text = true
	btn_select.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	btn_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_select.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn_select.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_select.tooltip_text = track.name
	btn_select.add_theme_font_size_override("font_size", 11)

	btn_select.pressed.connect(func():
		selected_track_id = track.id
		_highlight_selected()
		track_selected.emit(track.id)
	)
	hbox.add_child(btn_select)

	# Volume readout
	var vol_label: Label = Label.new()
	vol_label.text = "%d%%" % int(track.volume * 100.0)
	vol_label.custom_minimum_size = Vector2(28, 0)
	vol_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vol_label.add_theme_font_size_override("font_size", 10)
	vol_label.add_theme_color_override("font_color", pal["text_dim"])
	hbox.add_child(vol_label)

	# Volume Slider
	var vol_slider: HSlider = HSlider.new()
	vol_slider.min_value = 0.0
	vol_slider.max_value = 1.5
	vol_slider.step = 0.01
	vol_slider.custom_minimum_size = Vector2(42, 0)
	vol_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vol_slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	vol_slider.tooltip_text = LocalizationData.tr_key("TOOLTIP_VOL_SLIDER")
	hbox.add_child(vol_slider)
	vol_slider.set_value_no_signal(track.volume)
	vol_slider.value_changed.connect(func(val: float):
		track.volume = val
		vol_label.text = "%d%%" % int(val * 100.0)
		track_volume_changed.emit(track.id, val)
	)

	# Mute Button (with audio icon)
	var btn_mute: Button = Button.new()
	btn_mute.toggle_mode = true
	btn_mute.button_pressed = track.muted
	btn_mute.text = "🔇" if track.muted else "🔊"
	btn_mute.custom_minimum_size = Vector2(24, 22)
	btn_mute.add_theme_font_size_override("font_size", 11)
	btn_mute.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_mute.tooltip_text = "Unmute Track (Currently Muted)" if track.muted else "Mute Track (Click to silence)"
	if track.muted:
		btn_mute.modulate = Color(1.4, 0.4, 0.4)
	else:
		btn_mute.modulate = Color(1.0, 1.0, 1.0)
	btn_mute.toggled.connect(func(toggled: bool):
		track.muted = toggled
		btn_mute.text = "🔇" if toggled else "🔊"
		btn_mute.modulate = Color(1.4, 0.4, 0.4) if toggled else Color(1.0, 1.0, 1.0)
		btn_mute.tooltip_text = "Unmute Track (Currently Muted)" if toggled else "Mute Track (Click to silence)"
		indicator.color = pal["text_dim"] if toggled else pal["primary"]
		track_mute_toggled.emit(track.id, toggled)
	)
	hbox.add_child(btn_mute)

	# Solo Button
	var btn_solo: Button = Button.new()
	btn_solo.text = "S"
	btn_solo.toggle_mode = true
	btn_solo.button_pressed = track.solo
	btn_solo.custom_minimum_size = Vector2(20, 22)
	btn_solo.add_theme_font_size_override("font_size", 10)
	btn_solo.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_solo.tooltip_text = LocalizationData.tr_key("TOOLTIP_SOLO")
	if track.solo:
		btn_solo.modulate = Color(1.4, 1.2, 0.2)
		btn_solo.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	else:
		btn_solo.modulate = Color(1.0, 1.0, 1.0)
	btn_solo.toggled.connect(func(toggled: bool):
		track.solo = toggled
		btn_solo.modulate = Color(1.4, 1.2, 0.2) if toggled else Color(1.0, 1.0, 1.0)
		btn_solo.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2) if toggled else pal["text_main"])
		track_solo_toggled.emit(track.id, toggled)
	)
	hbox.add_child(btn_solo)

	# Crossfade (Continuous Loop) Button
	var btn_crossfade: Button = Button.new()
	btn_crossfade.text = "∞"
	btn_crossfade.custom_minimum_size = Vector2(22, 22)
	btn_crossfade.add_theme_font_size_override("font_size", 11)
	btn_crossfade.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_crossfade.tooltip_text = "Continuous Loop (Crossfade: %s)" % ("On" if track.crossfade else "Off")
	var is_continuous: bool = (track.trigger.mode == SoundscapeData.TriggerMode.CONTINUOUS_LOOP)
	if is_continuous:
		btn_crossfade.modulate = Color(0.2, 0.95, 1.4)
		btn_crossfade.add_theme_color_override("font_color", pal["primary"])
	else:
		btn_crossfade.modulate = Color(0.6, 0.6, 0.6)

	btn_crossfade.pressed.connect(func():
		track.trigger.mode = SoundscapeData.TriggerMode.CONTINUOUS_LOOP
		rebuild_list()
		track_trigger_mode_changed.emit(track.id)
	)
	hbox.add_child(btn_crossfade)

	# Random Interval Button
	var btn_random: Button = Button.new()
	btn_random.text = "⇌"
	btn_random.custom_minimum_size = Vector2(22, 22)
	btn_random.add_theme_font_size_override("font_size", 10)
	btn_random.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_random.tooltip_text = LocalizationData.tr_key("TOOLTIP_RANDOM")
	var is_random: bool = (track.trigger.mode == SoundscapeData.TriggerMode.RANDOM_INTERVAL)
	if is_random:
		btn_random.modulate = Color(0.2, 1.4, 0.8)
		btn_random.add_theme_color_override("font_color", Color(0.2, 0.95, 0.6))
	else:
		btn_random.modulate = Color(0.6, 0.6, 0.6)

	btn_random.pressed.connect(func():
		if track.trigger.mode == SoundscapeData.TriggerMode.RANDOM_INTERVAL:
			track.trigger.mode = SoundscapeData.TriggerMode.CONTINUOUS_LOOP
		else:
			track.trigger.mode = SoundscapeData.TriggerMode.RANDOM_INTERVAL
			rate_picker_requested.emit(track.id)
		rebuild_list()
		track_trigger_mode_changed.emit(track.id)
	)
	hbox.add_child(btn_random)

	# Rate Badge Button (Only visible when Random Interval is active)
	if is_random:
		var btn_rate: Button = Button.new()
		btn_rate.text = track.trigger.get_rate_label()
		btn_rate.custom_minimum_size = Vector2(50, 20)
		btn_rate.add_theme_font_size_override("font_size", 9)
		btn_rate.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_rate.add_theme_color_override("font_color", Color(0.2, 0.95, 0.6))
		btn_rate.tooltip_text = "Rate: %s (Click to change frequency)" % track.trigger.get_rate_label()
		btn_rate.pressed.connect(func():
			rate_picker_requested.emit(track.id)
		)
		hbox.add_child(btn_rate)

	# Delete Button
	var btn_del: Button = Button.new()
	btn_del.text = "✕"
	btn_del.custom_minimum_size = Vector2(20, 20)
	btn_del.add_theme_font_size_override("font_size", 10)
	btn_del.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_del.tooltip_text = LocalizationData.tr_key("TOOLTIP_DELETE")
	btn_del.pressed.connect(func():
		track_deleted.emit(track.id)
	)
	hbox.add_child(btn_del)

	return panel

func _highlight_selected() -> void:
	if items_container == null:
		return
	for child in items_container.get_children():
		if child is PanelContainer:
			var is_sel: bool = child.name == ("TrackItem_" + selected_track_id)
			if is_sel:
				child.modulate = Color(1.25, 1.25, 1.1)
			else:
				child.modulate = Color(1.0, 1.0, 1.0)
