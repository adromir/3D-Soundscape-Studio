class_name VisualAmbientDialog
extends Window

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio



signal lighting_saved()

var project_lighting: SoundscapeData.LightingProjectConfig = null
var current_tracks: Array[SoundscapeData.TrackConfig] = []
var _ha_client: HomeAssistantClient = null

var _available_entities: Array[Dictionary] = []

# UI Controls
var _chk_enabled: CheckBox = null
var _edit_endpoint: LineEdit = null
var _edit_token: LineEdit = null
var _btn_test_conn: Button = null
var _lbl_conn_status: Label = null
var _btn_fetch_entities: Button = null
var _lights_container: VBoxContainer = null
var _btn_add_light: Button = null

func _ready() -> void:
	title = ""
	size = Vector2i(650, 520)
	exclusive = true
	wrap_controls = true
	transient = true
	borderless = true
	visible = false
	close_requested.connect(hide)

	_ha_client = HomeAssistantClient.new()
	_ha_client.name = "DialogHAClient"
	add_child(_ha_client)
	_ha_client.connection_tested.connect(_on_connection_tested)
	_ha_client.light_entities_fetched.connect(_on_entities_fetched)

	_build_ui()

func _build_ui() -> void:
	var pal: Dictionary = ThemeManager.get_palette()
	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.clip_contents = true

	var outer_sb: StyleBoxFlat = StyleBoxFlat.new()
	outer_sb.bg_color = pal["panel_bg"]
	outer_sb.border_color = pal["panel_border_glow"]
	outer_sb.set_border_width_all(1)
	outer_sb.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel", outer_sb)
	add_child(panel)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	panel.add_child(main_vbox)

	# Header Panel
	var header_panel: PanelContainer = PanelContainer.new()
	var header_sb: StyleBoxFlat = StyleBoxFlat.new()
	header_sb.bg_color = pal["btn_normal"]
	header_sb.border_color = pal["panel_border"]
	header_sb.border_width_bottom = 1
	header_sb.corner_radius_top_left = 12
	header_sb.corner_radius_top_right = 12
	header_sb.content_margin_left = 16
	header_sb.content_margin_right = 12
	header_sb.content_margin_top = 8
	header_sb.content_margin_bottom = 8
	header_panel.add_theme_stylebox_override("panel", header_sb)
	main_vbox.add_child(header_panel)

	var header_hbox: HBoxContainer = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	header_panel.add_child(header_hbox)

	var title_lbl: Label = Label.new()
	title_lbl.text = "Visual Ambient Editor — Home Assistant & Zigbee Lighting"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", pal["primary"])
	header_hbox.add_child(title_lbl)

	var btn_close_top: Button = Button.new()
	btn_close_top.text = "X"
	btn_close_top.custom_minimum_size = Vector2(24, 24)
	btn_close_top.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close_top.pressed.connect(hide)
	header_hbox.add_child(btn_close_top)

	# Content Scroll
	var margin: MarginContainer = MarginContainer.new()
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	main_vbox.add_child(margin)

	var content_vbox: VBoxContainer = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(content_vbox)

	# HA Connection Group
	var conn_panel: PanelContainer = PanelContainer.new()
	var conn_sb: StyleBoxFlat = StyleBoxFlat.new()
	conn_sb.bg_color = pal["btn_normal"]
	conn_sb.border_color = pal["panel_border"]
	conn_sb.set_border_width_all(1)
	conn_sb.set_corner_radius_all(8)
	conn_sb.content_margin_left = 12
	conn_sb.content_margin_right = 12
	conn_sb.content_margin_top = 8
	conn_sb.content_margin_bottom = 8
	conn_panel.add_theme_stylebox_override("panel", conn_sb)
	content_vbox.add_child(conn_panel)

	var conn_vbox: VBoxContainer = VBoxContainer.new()
	conn_vbox.add_theme_constant_override("separation", 6)
	conn_panel.add_child(conn_vbox)

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	conn_vbox.add_child(top_row)

	_chk_enabled = CheckBox.new()
	_chk_enabled.text = "Enable Visual Ambient Lighting Integration"
	_chk_enabled.add_theme_font_size_override("font_size", 11)
	top_row.add_child(_chk_enabled)

	var ep_row: HBoxContainer = HBoxContainer.new()
	ep_row.add_theme_constant_override("separation", 6)
	conn_vbox.add_child(ep_row)

	var lbl_ep: Label = Label.new()
	lbl_ep.text = "HA URL:"
	lbl_ep.add_theme_font_size_override("font_size", 10)
	ep_row.add_child(lbl_ep)

	_edit_endpoint = LineEdit.new()
	_edit_endpoint.placeholder_text = "http://homeassistant.local:8123"
	_edit_endpoint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_edit_endpoint.custom_minimum_size = Vector2(0, 24)
	_edit_endpoint.add_theme_font_size_override("font_size", 10)
	ep_row.add_child(_edit_endpoint)

	var lbl_tok: Label = Label.new()
	lbl_tok.text = "Token:"
	lbl_tok.add_theme_font_size_override("font_size", 10)
	ep_row.add_child(lbl_tok)

	_edit_token = LineEdit.new()
	_edit_token.placeholder_text = "Long-Lived Access Token..."
	_edit_token.secret = true
	_edit_token.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_edit_token.custom_minimum_size = Vector2(0, 24)
	_edit_token.add_theme_font_size_override("font_size", 10)
	ep_row.add_child(_edit_token)

	_btn_test_conn = Button.new()
	_btn_test_conn.text = "Test Connection"
	_btn_test_conn.custom_minimum_size = Vector2(100, 24)
	_btn_test_conn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_test_conn.add_theme_font_size_override("font_size", 10)
	_btn_test_conn.pressed.connect(_test_connection)
	ep_row.add_child(_btn_test_conn)

	_btn_fetch_entities = Button.new()
	_btn_fetch_entities.text = "Fetch Lights ⟳"
	_btn_fetch_entities.custom_minimum_size = Vector2(90, 24)
	_btn_fetch_entities.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_fetch_entities.add_theme_font_size_override("font_size", 10)
	_btn_fetch_entities.pressed.connect(_fetch_entities)
	ep_row.add_child(_btn_fetch_entities)

	_lbl_conn_status = Label.new()
	_lbl_conn_status.text = ""
	_lbl_conn_status.add_theme_font_size_override("font_size", 9)
	conn_vbox.add_child(_lbl_conn_status)

	# Lights List Header
	var lights_header: HBoxContainer = HBoxContainer.new()
	lights_header.add_theme_constant_override("separation", 10)
	content_vbox.add_child(lights_header)

	var lbl_lights_title: Label = Label.new()
	lbl_lights_title.text = "Scene Virtual Lights & Audio-Reactive Triggers:"
	lbl_lights_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_lights_title.add_theme_font_size_override("font_size", 11)
	lights_header.add_child(lbl_lights_title)

	_btn_add_light = Button.new()
	_btn_add_light.text = "+ Add Scene Light"
	_btn_add_light.icon = load("res://assets/icons/plus.svg")
	_btn_add_light.expand_icon = true
	_btn_add_light.custom_minimum_size = Vector2(130, 26)
	_btn_add_light.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_add_light.add_theme_font_size_override("font_size", 10)
	_btn_add_light.pressed.connect(_add_new_light)
	lights_header.add_child(_btn_add_light)

	# Scrollable Lights Container
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_vbox.add_child(scroll)

	_lights_container = VBoxContainer.new()
	_lights_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lights_container.add_theme_constant_override("separation", 8)
	scroll.add_child(_lights_container)

	# Bottom Actions
	var bottom_hbox: HBoxContainer = HBoxContainer.new()
	bottom_hbox.alignment = BoxContainer.ALIGNMENT_END
	bottom_hbox.add_theme_constant_override("separation", 8)
	main_vbox.add_child(bottom_hbox)

	var btn_cancel: Button = Button.new()
	btn_cancel.text = "Cancel"
	btn_cancel.pressed.connect(hide)
	bottom_hbox.add_child(btn_cancel)

	var btn_save: Button = Button.new()
	btn_save.text = "Save Lighting Config"
	btn_save.icon = load("res://assets/icons/save.svg")
	btn_save.expand_icon = true
	btn_save.custom_minimum_size = Vector2(150, 30)
	btn_save.pressed.connect(_save_and_close)
	bottom_hbox.add_child(btn_save)

func setup(lighting_cfg: SoundscapeData.LightingProjectConfig, tracks: Array[SoundscapeData.TrackConfig]) -> void:
	project_lighting = lighting_cfg
	current_tracks = tracks

	if project_lighting:
		_chk_enabled.button_pressed = project_lighting.enabled
		_edit_endpoint.text = project_lighting.ha_endpoint
		_edit_token.text = project_lighting.ha_token
		_ha_client.configure(project_lighting.ha_endpoint, project_lighting.ha_token)

	_rebuild_lights_list()

func _test_connection() -> void:
	if _ha_client == null: return
	_ha_client.configure(_edit_endpoint.text, _edit_token.text)
	_lbl_conn_status.text = "Connecting to Home Assistant..."
	_lbl_conn_status.add_theme_color_override("font_color", ThemeManager.get_palette()["text_dim"])
	_ha_client.test_connection()

func _on_connection_tested(success: bool, msg: String) -> void:
	_lbl_conn_status.text = msg
	var col: Color = Color(0.2, 1.0, 0.4) if success else Color(1.0, 0.3, 0.3)
	_lbl_conn_status.add_theme_color_override("font_color", col)

func _fetch_entities() -> void:
	if _ha_client == null: return
	_ha_client.configure(_edit_endpoint.text, _edit_token.text)
	_lbl_conn_status.text = "Fetching light entities..."
	_ha_client.fetch_light_entities()

func _on_entities_fetched(entities: Array[Dictionary]) -> void:
	_available_entities = entities
	_lbl_conn_status.text = "Fetched %d light entities from Home Assistant." % entities.size()
	_lbl_conn_status.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	_rebuild_lights_list()

func _add_new_light() -> void:
	if project_lighting == null: return
	var l: SoundscapeData.LightEntityConfig = SoundscapeData.LightEntityConfig.new()
	l.name = "Light %d" % (project_lighting.lights.size() + 1)
	if not _available_entities.is_empty():
		l.entity_id = _available_entities[0].get("entity_id", "")
		l.name = _available_entities[0].get("name", l.name)
	project_lighting.lights.append(l)
	_rebuild_lights_list()

func _rebuild_lights_list() -> void:
	if _lights_container == null or project_lighting == null: return

	for child in _lights_container.get_children():
		child.queue_free()

	if project_lighting.lights.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No scene lights added yet. Click '+ Add Scene Light' above to configure smart lighting!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 10)
		empty_lbl.add_theme_color_override("font_color", ThemeManager.get_palette()["text_dim"])
		_lights_container.add_child(empty_lbl)
		return

	for i in range(project_lighting.lights.size()):
		var light_cfg: SoundscapeData.LightEntityConfig = project_lighting.lights[i]
		var card: PanelContainer = _create_light_card(light_cfg, i)
		_lights_container.add_child(card)

func _create_light_card(l: SoundscapeData.LightEntityConfig, idx: int) -> PanelContainer:
	var pal: Dictionary = ThemeManager.get_palette()
	var card: PanelContainer = PanelContainer.new()
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = pal["btn_normal"]
	sb.border_color = pal["panel_border"]
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", sb)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	# Row 1: Name, Entity ID, Enabled, Delete
	var row1: HBoxContainer = HBoxContainer.new()
	row1.add_theme_constant_override("separation", 8)
	vbox.add_child(row1)

	var chk_active: CheckBox = CheckBox.new()
	chk_active.button_pressed = l.enabled
	chk_active.toggled.connect(func(v: bool): l.enabled = v)
	row1.add_child(chk_active)

	var edit_name: LineEdit = LineEdit.new()
	edit_name.text = l.name
	edit_name.custom_minimum_size = Vector2(130, 24)
	edit_name.add_theme_font_size_override("font_size", 10)
	edit_name.text_changed.connect(func(t: String): l.name = t)
	row1.add_child(edit_name)

	var opt_entity: OptionButton = OptionButton.new()
	opt_entity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opt_entity.custom_minimum_size = Vector2(0, 24)
	opt_entity.add_theme_font_size_override("font_size", 10)
	if _available_entities.is_empty():
		opt_entity.add_item(l.entity_id if not l.entity_id.is_empty() else "light.entity_id", 0)
	else:
		for e_idx in range(_available_entities.size()):
			var ent = _available_entities[e_idx]
			opt_entity.add_item("%s (%s)" % [ent["name"], ent["entity_id"]], e_idx)
			if ent["entity_id"] == l.entity_id:
				opt_entity.select(e_idx)
	opt_entity.item_selected.connect(func(s_idx: int):
		if not _available_entities.is_empty() and s_idx < _available_entities.size():
			l.entity_id = _available_entities[s_idx]["entity_id"]
			l.name = _available_entities[s_idx]["name"]
			edit_name.text = l.name
	)
	row1.add_child(opt_entity)

	var btn_del: Button = Button.new()
	btn_del.text = "X"
	btn_del.custom_minimum_size = Vector2(24, 24)
	btn_del.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_del.pressed.connect(func():
		project_lighting.lights.remove_at(idx)
		_rebuild_lights_list()
	)
	row1.add_child(btn_del)

	# Row 2: Effect Mode, Color Picker, Brightness, Trigger Sync
	var row2: HBoxContainer = HBoxContainer.new()
	row2.add_theme_constant_override("separation", 8)
	vbox.add_child(row2)

	var lbl_mode: Label = Label.new()
	lbl_mode.text = "Effect:"
	lbl_mode.add_theme_font_size_override("font_size", 10)
	row2.add_child(lbl_mode)

	var opt_mode: OptionButton = OptionButton.new()
	opt_mode.add_theme_font_size_override("font_size", 10)
	opt_mode.add_item("Static Ambient", SoundscapeData.LightEffectMode.STATIC)
	opt_mode.add_item("Fire / Candle Hearth Flicker", SoundscapeData.LightEffectMode.CANDLE_HEARTH_FLICKER)
	opt_mode.add_item("Audio Trigger Strobe Flash", SoundscapeData.LightEffectMode.LIGHTNING_TRIGGER_FLASH)
	opt_mode.add_item("Water Shimmer", SoundscapeData.LightEffectMode.WATER_SHIMMER)
	opt_mode.add_item("Walkable Proximity Dimming", SoundscapeData.LightEffectMode.PROXIMITY_WALK)
	for itm_i in range(opt_mode.item_count):
		if opt_mode.get_item_id(itm_i) == l.effect_mode:
			opt_mode.select(itm_i)
			break
	opt_mode.item_selected.connect(func(m_idx: int): l.effect_mode = opt_mode.get_item_id(m_idx))
	row2.add_child(opt_mode)

	var lbl_col: Label = Label.new()
	lbl_col.text = "Color:"
	lbl_col.add_theme_font_size_override("font_size", 10)
	row2.add_child(lbl_col)

	var col_picker: ColorPickerButton = ColorPickerButton.new()
	col_picker.color = l.base_rgb
	col_picker.custom_minimum_size = Vector2(36, 24)
	col_picker.color_changed.connect(func(c: Color): l.base_rgb = c)
	row2.add_child(col_picker)

	var lbl_bri: Label = Label.new()
	lbl_bri.text = "Brightness:"
	lbl_bri.add_theme_font_size_override("font_size", 10)
	row2.add_child(lbl_bri)

	var bri_slider: HSlider = HSlider.new()
	bri_slider.min_value = 1
	bri_slider.max_value = 100
	bri_slider.value = l.brightness_pct
	bri_slider.custom_minimum_size = Vector2(80, 20)
	bri_slider.size_flags_vertical = 4
	bri_slider.value_changed.connect(func(v: float): l.brightness_pct = int(v))
	row2.add_child(bri_slider)

	var btn_test_flash: Button = Button.new()
	btn_test_flash.text = "Test Flash"
	btn_test_flash.custom_minimum_size = Vector2(80, 24)
	btn_test_flash.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_test_flash.add_theme_font_size_override("font_size", 9)
	btn_test_flash.pressed.connect(func():
		_ha_client.trigger_lightning_flash(l.entity_id, l.flash_color, l.base_rgb, l.brightness_pct, l.flash_duration_ms)
	)
	row2.add_child(btn_test_flash)

	return card

func _save_and_close() -> void:
	if project_lighting:
		project_lighting.enabled = _chk_enabled.button_pressed
		project_lighting.ha_endpoint = _edit_endpoint.text.strip_edges()
		project_lighting.ha_token = _edit_token.text.strip_edges()
	lighting_saved.emit()
	hide()
