class_name SoundscapeBrowser
extends PanelContainer

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

const AppPaths = preload("res://src/core/app_paths.gd")

signal soundscape_loaded(project: SoundscapeData.SoundscapeProject)

var _client: AmbientMixerClient = null
var _search_query: String = ""
var _selected_slug_for_cover: String = ""
var _current_category: String = "ALL"
var _categories: Array[String] = ["ALL", "Nature", "Weather", "Ambient", "Relaxation", "Fantasy", "Sci-Fi", "Custom"]

const DEFAULT_CATEGORIES: Array[String] = ["ALL", "Nature", "Weather", "Ambient", "Relaxation", "Fantasy", "Sci-Fi", "Custom"]

static func get_categories_file() -> String:
	return AppPaths.get_soundscape_categories_file()

@onready var search_input: LineEdit = $VBox/TopBar/SearchBox/SearchInput if has_node("VBox/TopBar/SearchBox/SearchInput") else null
@onready var btn_download: Button = $VBox/TopBar/BtnDownload if has_node("VBox/TopBar/BtnDownload") else null
@onready var category_hbox: HBoxContainer = $VBox/CategoryHBox if has_node("VBox/CategoryHBox") else null
@onready var items_container: GridContainer = $VBox/LibraryScroll/ItemsContainer if has_node("VBox/LibraryScroll/ItemsContainer") else null
@onready var cover_file_dialog: FileDialog = $CoverFileDialog if has_node("CoverFileDialog") else null

var _add_cat_dialog: Window = null
var _download_dialog: Window = null
var _edit_dialog: Window = null
var _category_buttons: Array[Button] = []

# References for live download dialog updates
var _dlg_download_btn: Button = null
var _dlg_progress_bar: ProgressBar = null
var _dlg_status_lbl: Label = null

func _ready() -> void:
	_client = AmbientMixerClient.new()
	add_child(_client)
	_client.progress_changed.connect(_on_client_progress)
	_client.download_completed.connect(_on_client_completed)
	_client.download_failed.connect(_on_client_failed)

	if btn_download:
		btn_download.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_download.pressed.connect(_open_download_import_dialog)

	if search_input:
		search_input.text_changed.connect(_on_search_changed)

	if cover_file_dialog:
		cover_file_dialog.file_selected.connect(_on_cover_file_selected)

	_load_categories()
	_setup_category_filters()
	refresh_library()
	update_localization()
	apply_theme(ThemeManager.current_theme)

func apply_theme(mode: ThemeManager.ThemeMode) -> void:
	ThemeManager.apply_theme(self, mode)
	_update_category_buttons()
	refresh_library()

func update_localization() -> void:
	if btn_download:
		btn_download.text = LocalizationData.tr_key("BTN_DOWNLOAD_IMPORT")
		btn_download.tooltip_text = LocalizationData.tr_key("TOOLTIP_DOWNLOAD_IMPORT")
	if search_input:
		search_input.placeholder_text = LocalizationData.tr_key("SEARCH_SOUNDSCAPES_PLACEHOLDER")
	_setup_category_filters()
	refresh_library()

func _load_categories() -> void:
	_categories = DEFAULT_CATEGORIES.duplicate()
	if FileAccess.file_exists(get_categories_file()):
		var f: FileAccess = FileAccess.open(get_categories_file(), FileAccess.READ)
		if f:
			var json: JSON = JSON.new()
			if json.parse(f.get_as_text()) == OK and json.data is Array:
				for cat in json.data:
					var c_str: String = str(cat).strip_edges()
					if not c_str.is_empty() and not _categories.has(c_str):
						_categories.append(c_str)
			f.close()

func _save_categories() -> void:
	var custom_only: Array[String] = []
	for c in _categories:
		if not DEFAULT_CATEGORIES.has(c):
			custom_only.append(c)
	var f: FileAccess = FileAccess.open(get_categories_file(), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(custom_only, "\t"))
		f.close()

func _setup_category_filters() -> void:
	if category_hbox == null:
		return

	for child in category_hbox.get_children():
		child.queue_free()
	_category_buttons.clear()

	for cat in _categories:
		var btn: Button = Button.new()
		btn.text = cat
		btn.toggle_mode = true
		btn.button_pressed = (cat == _current_category)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(func():
			_current_category = cat
			_update_category_buttons()
			refresh_library()
		)
		category_hbox.add_child(btn)
		_category_buttons.append(btn)

	# + Add Category Button
	var btn_add_cat: Button = Button.new()
	btn_add_cat.text = "+ " + LocalizationData.tr_key("BTN_ADD_CATEGORY")
	btn_add_cat.tooltip_text = LocalizationData.tr_key("TOOLTIP_ADD_CATEGORY")
	btn_add_cat.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_add_cat.add_theme_font_size_override("font_size", 10)
	btn_add_cat.pressed.connect(_prompt_add_category)
	category_hbox.add_child(btn_add_cat)

	_update_category_buttons()

func _update_category_buttons() -> void:
	var pal: Dictionary = ThemeManager.get_palette()
	var is_light: bool = (ThemeManager.current_theme == ThemeManager.ThemeMode.LIGHT)
	for btn in _category_buttons:
		var active: bool = (btn.text == _current_category)
		btn.button_pressed = active
		btn.modulate = Color.WHITE
		if active:
			btn.add_theme_color_override("font_color", pal.get("primary", Color.WHITE) if not is_light else Color(0.0, 0.35, 0.65))
			btn.add_theme_color_override("font_pressed_color", pal.get("primary", Color.WHITE) if not is_light else Color(0.0, 0.35, 0.65))
		else:
			btn.add_theme_color_override("font_color", pal.get("text_dim", Color(0.6, 0.6, 0.6)))

# ==================== DEDICATED DOWNLOAD & IMPORT DIALOG ====================

func _open_download_import_dialog() -> void:
	if _download_dialog and is_instance_valid(_download_dialog):
		_download_dialog.queue_free()

	_download_dialog = Window.new()
	_download_dialog.title = ""
	_download_dialog.size = Vector2i(540, 260)
	_download_dialog.exclusive = true
	_download_dialog.wrap_controls = true
	_download_dialog.transient = true
	_download_dialog.borderless = true
	_download_dialog.transparent = true
	_download_dialog.transparent_bg = true
	_download_dialog.close_requested.connect(_download_dialog.queue_free)

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
	_download_dialog.add_child(panel)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	panel.add_child(main_vbox)

	# --- Header ---
	var header_panel: PanelContainer = PanelContainer.new()
	var header_sb: StyleBoxFlat = StyleBoxFlat.new()
	header_sb.bg_color = pal["btn_normal"]
	header_sb.border_color = pal["panel_border"]
	header_sb.border_width_bottom = 1
	header_sb.corner_radius_top_left = 12
	header_sb.corner_radius_top_right = 12
	header_sb.content_margin_left = 16
	header_sb.content_margin_right = 12
	header_sb.content_margin_top = 10
	header_sb.content_margin_bottom = 10
	header_panel.add_theme_stylebox_override("panel", header_sb)
	main_vbox.add_child(header_panel)

	var header_hbox: HBoxContainer = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	header_panel.add_child(header_hbox)

	var header_icon: TextureRect = TextureRect.new()
	header_icon.custom_minimum_size = Vector2(18, 18)
	header_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header_icon.texture = load("res://assets/icons/download.svg")
	header_icon.modulate = pal["primary"]
	header_hbox.add_child(header_icon)

	var title_lbl: Label = Label.new()
	title_lbl.text = LocalizationData.tr_key("DLG_DOWNLOAD_TITLE")
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", pal["primary"])
	header_hbox.add_child(title_lbl)

	var btn_close_top: Button = Button.new()
	btn_close_top.text = "✕"
	btn_close_top.custom_minimum_size = Vector2(24, 24)
	btn_close_top.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close_top.pressed.connect(_download_dialog.queue_free)
	header_hbox.add_child(btn_close_top)

	# --- Content ---
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 16)
	main_vbox.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var url_lbl: Label = Label.new()
	url_lbl.text = LocalizationData.tr_key("LBL_DOWNLOAD_URL")
	url_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(url_lbl)

	var url_edit: LineEdit = LineEdit.new()
	url_edit.placeholder_text = "https://ambient-mixer.com/mix/tropical-rain-forest or ID (e.g. 12345)"
	url_edit.custom_minimum_size = Vector2(0, 32)
	vbox.add_child(url_edit)

	# Category Selector Row
	var cat_row: HBoxContainer = HBoxContainer.new()
	cat_row.add_theme_constant_override("separation", 8)
	vbox.add_child(cat_row)

	var cat_lbl: Label = Label.new()
	cat_lbl.text = LocalizationData.tr_key("LBL_CATEGORY")
	cat_lbl.add_theme_font_size_override("font_size", 11)
	cat_row.add_child(cat_lbl)

	var cat_option: OptionButton = OptionButton.new()
	cat_option.custom_minimum_size = Vector2(160, 28)
	var cat_idx: int = 0
	for c in _categories:
		if c != "ALL":
			cat_option.add_item(c, cat_idx)
			if c == _current_category:
				cat_option.select(cat_idx)
			cat_idx += 1
	cat_row.add_child(cat_option)

	# Progress & Status
	_dlg_progress_bar = ProgressBar.new()
	_dlg_progress_bar.custom_minimum_size = Vector2(0, 14)
	_dlg_progress_bar.visible = false
	vbox.add_child(_dlg_progress_bar)

	_dlg_status_lbl = Label.new()
	_dlg_status_lbl.add_theme_font_size_override("font_size", 11)
	_dlg_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dlg_status_lbl.visible = false
	vbox.add_child(_dlg_status_lbl)

	# Button Row
	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.add_theme_constant_override("separation", 10)
	vbox.add_child(btn_row)

	var btn_cancel: Button = Button.new()
	btn_cancel.text = LocalizationData.tr_key("SETTINGS_CANCEL")
	btn_cancel.custom_minimum_size = Vector2(80, 30)
	btn_cancel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_cancel.pressed.connect(_download_dialog.queue_free)
	btn_row.add_child(btn_cancel)

	_dlg_download_btn = Button.new()
	_dlg_download_btn.text = LocalizationData.tr_key("BTN_DOWNLOAD_IMPORT")
	_dlg_download_btn.custom_minimum_size = Vector2(150, 30)
	_dlg_download_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_dlg_download_btn.pressed.connect(func():
		var u_text: String = url_edit.text.strip_edges()
		if u_text.is_empty():
			return
		_dlg_download_btn.disabled = true
		_dlg_progress_bar.visible = true
		_dlg_status_lbl.visible = true
		_dlg_progress_bar.value = 0
		_dlg_status_lbl.text = "Starting download..."
		var chosen_cat: String = cat_option.get_item_text(cat_option.selected) if cat_option.item_count > 0 else "Nature"
		_client.start_import_from_url(u_text, chosen_cat)
	)
	btn_row.add_child(_dlg_download_btn)

	ThemeManager.apply_theme(_download_dialog, ThemeManager.current_theme)
	add_child(_download_dialog)
	_download_dialog.popup_centered()

# ==================== EDIT SOUNDSCAPE DETAILS DIALOG ====================

func _prompt_edit_soundscape(item: Dictionary) -> void:
	if _edit_dialog and is_instance_valid(_edit_dialog):
		_edit_dialog.queue_free()

	var folder_name: String = item.get("folder_name", item.get("slug", ""))
	var curr_title: String = item.get("title", "")
	var curr_author: String = item.get("author", "Unknown")
	var curr_cat: String = item.get("category", "Nature")

	_edit_dialog = Window.new()
	_edit_dialog.title = ""
	_edit_dialog.size = Vector2i(480, 280)
	_edit_dialog.exclusive = true
	_edit_dialog.wrap_controls = true
	_edit_dialog.transient = true
	_edit_dialog.borderless = true
	_edit_dialog.transparent = true
	_edit_dialog.transparent_bg = true
	_edit_dialog.close_requested.connect(_edit_dialog.queue_free)

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
	_edit_dialog.add_child(panel)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	panel.add_child(main_vbox)

	# --- Header ---
	var header_panel: PanelContainer = PanelContainer.new()
	var header_sb: StyleBoxFlat = StyleBoxFlat.new()
	header_sb.bg_color = pal["btn_normal"]
	header_sb.border_color = pal["panel_border"]
	header_sb.border_width_bottom = 1
	header_sb.corner_radius_top_left = 12
	header_sb.corner_radius_top_right = 12
	header_sb.content_margin_left = 16
	header_sb.content_margin_right = 12
	header_sb.content_margin_top = 10
	header_sb.content_margin_bottom = 10
	header_panel.add_theme_stylebox_override("panel", header_sb)
	main_vbox.add_child(header_panel)

	var header_hbox: HBoxContainer = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	header_panel.add_child(header_hbox)

	var header_icon: TextureRect = TextureRect.new()
	header_icon.custom_minimum_size = Vector2(18, 18)
	header_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header_icon.texture = load("res://assets/icons/edit.svg")
	header_icon.modulate = pal["primary"]
	header_hbox.add_child(header_icon)

	var title_lbl: Label = Label.new()
	title_lbl.text = LocalizationData.tr_key("DLG_EDIT_SOUNDSCAPE_TITLE")
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", pal["primary"])
	header_hbox.add_child(title_lbl)

	var btn_close_top: Button = Button.new()
	btn_close_top.text = "✕"
	btn_close_top.custom_minimum_size = Vector2(24, 24)
	btn_close_top.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close_top.pressed.connect(_edit_dialog.queue_free)
	header_hbox.add_child(btn_close_top)

	# --- Content ---
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 16)
	main_vbox.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var name_lbl: Label = Label.new()
	name_lbl.text = LocalizationData.tr_key("LBL_SOUNDSCAPE_TITLE")
	name_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(name_lbl)

	var name_edit: LineEdit = LineEdit.new()
	name_edit.text = curr_title
	name_edit.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(name_edit)

	var author_lbl: Label = Label.new()
	author_lbl.text = LocalizationData.tr_key("LBL_AUTHOR")
	author_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(author_lbl)

	var author_edit: LineEdit = LineEdit.new()
	author_edit.text = curr_author
	author_edit.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(author_edit)

	var cat_lbl: Label = Label.new()
	cat_lbl.text = LocalizationData.tr_key("LBL_CATEGORY")
	cat_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(cat_lbl)

	var cat_opt: OptionButton = OptionButton.new()
	cat_opt.custom_minimum_size = Vector2(0, 30)
	var sel_cat_idx: int = 0
	var c_idx: int = 0
	for c in _categories:
		if c != "ALL":
			cat_opt.add_item(c, c_idx)
			if c.to_lower() == curr_cat.to_lower():
				sel_cat_idx = c_idx
			c_idx += 1
	if cat_opt.item_count > 0:
		cat_opt.select(sel_cat_idx)
	vbox.add_child(cat_opt)

	# Button Row
	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.add_theme_constant_override("separation", 10)
	vbox.add_child(btn_row)

	var btn_cancel: Button = Button.new()
	btn_cancel.text = LocalizationData.tr_key("SETTINGS_CANCEL")
	btn_cancel.custom_minimum_size = Vector2(80, 30)
	btn_cancel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_cancel.pressed.connect(_edit_dialog.queue_free)
	btn_row.add_child(btn_cancel)

	var btn_save: Button = Button.new()
	btn_save.text = LocalizationData.tr_key("BTN_SAVE_CHANGES")
	btn_save.custom_minimum_size = Vector2(120, 30)
	btn_save.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_save.pressed.connect(func():
		var new_title: String = name_edit.text.strip_edges()
		var new_author: String = author_edit.text.strip_edges()
		var new_cat: String = cat_opt.get_item_text(cat_opt.selected) if cat_opt.item_count > 0 else "Nature"
		LibraryManager.update_soundscape_info(folder_name, new_title, new_cat, new_author)
		refresh_library()
		_edit_dialog.queue_free()
	)
	btn_row.add_child(btn_save)

	ThemeManager.apply_theme(_edit_dialog, ThemeManager.current_theme)
	add_child(_edit_dialog)
	_edit_dialog.popup_centered()

# ==================== ADD CATEGORY DIALOG ====================

func _prompt_add_category() -> void:
	if _add_cat_dialog and is_instance_valid(_add_cat_dialog):
		_add_cat_dialog.queue_free()

	_add_cat_dialog = Window.new()
	_add_cat_dialog.title = ""
	_add_cat_dialog.size = Vector2i(380, 160)
	_add_cat_dialog.exclusive = true
	_add_cat_dialog.wrap_controls = true
	_add_cat_dialog.transient = true
	_add_cat_dialog.borderless = true
	_add_cat_dialog.transparent = true
	_add_cat_dialog.transparent_bg = true
	_add_cat_dialog.close_requested.connect(_add_cat_dialog.queue_free)

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
	_add_cat_dialog.add_child(panel)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	panel.add_child(main_vbox)

	var header_panel: PanelContainer = PanelContainer.new()
	var header_sb: StyleBoxFlat = StyleBoxFlat.new()
	header_sb.bg_color = pal["btn_normal"]
	header_sb.border_color = pal["panel_border"]
	header_sb.border_width_bottom = 1
	header_sb.corner_radius_top_left = 12
	header_sb.corner_radius_top_right = 12
	header_sb.content_margin_left = 16
	header_sb.content_margin_right = 12
	header_sb.content_margin_top = 10
	header_sb.content_margin_bottom = 10
	header_panel.add_theme_stylebox_override("panel", header_sb)
	main_vbox.add_child(header_panel)

	var header_hbox: HBoxContainer = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	header_panel.add_child(header_hbox)

	var title_lbl: Label = Label.new()
	title_lbl.text = LocalizationData.tr_key("BTN_ADD_CATEGORY")
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", pal["primary"])
	header_hbox.add_child(title_lbl)

	var btn_close_top: Button = Button.new()
	btn_close_top.text = "✕"
	btn_close_top.custom_minimum_size = Vector2(24, 24)
	btn_close_top.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close_top.pressed.connect(_add_cat_dialog.queue_free)
	header_hbox.add_child(btn_close_top)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	main_vbox.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var lbl: Label = Label.new()
	lbl.text = LocalizationData.tr_key("LBL_CATEGORY")
	lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl)

	var edit: LineEdit = LineEdit.new()
	edit.placeholder_text = "e.g. Meditation, Atmosphere, Cyberpunk..."
	edit.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(edit)

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	var btn_cancel: Button = Button.new()
	btn_cancel.text = LocalizationData.tr_key("SETTINGS_CANCEL")
	btn_cancel.pressed.connect(_add_cat_dialog.queue_free)
	btn_row.add_child(btn_cancel)

	var btn_ok: Button = Button.new()
	btn_ok.text = LocalizationData.tr_key("BTN_ADD_CATEGORY")
	btn_ok.pressed.connect(func():
		var cat_name: String = edit.text.strip_edges()
		if not cat_name.is_empty() and not _categories.has(cat_name):
			_categories.append(cat_name)
			_save_categories()
			_setup_category_filters()
			_current_category = cat_name
			_update_category_buttons()
			refresh_library()
		_add_cat_dialog.queue_free()
	)
	btn_row.add_child(btn_ok)

	ThemeManager.apply_theme(_add_cat_dialog, ThemeManager.current_theme)
	add_child(_add_cat_dialog)
	_add_cat_dialog.popup_centered()

func _on_search_changed(query: String) -> void:
	_search_query = query.strip_edges().to_lower()
	refresh_library()

func _on_client_progress(curr: int, total: int, status_text: String) -> void:
	if _dlg_progress_bar:
		_dlg_progress_bar.max_value = total
		_dlg_progress_bar.value = curr
	if _dlg_status_lbl:
		_dlg_status_lbl.text = status_text

func _on_client_completed(_project_path: String, project: SoundscapeData.SoundscapeProject) -> void:
	if _dlg_download_btn: _dlg_download_btn.disabled = false
	if _dlg_progress_bar: _dlg_progress_bar.visible = false
	if _dlg_status_lbl:
		_dlg_status_lbl.text = "Downloaded successfully: " + project.title
	refresh_library()
	soundscape_loaded.emit(project)
	if _download_dialog and is_instance_valid(_download_dialog):
		_download_dialog.queue_free()

func _on_client_failed(err: String) -> void:
	if _dlg_download_btn: _dlg_download_btn.disabled = false
	if _dlg_progress_bar: _dlg_progress_bar.visible = false
	if _dlg_status_lbl:
		_dlg_status_lbl.text = "Error: " + err

func refresh_library() -> void:
	if items_container == null:
		return

	for child in items_container.get_children():
		child.queue_free()

	var list: Array[Dictionary] = LibraryManager.get_all_soundscapes()
	var pal: Dictionary = ThemeManager.get_palette()

	var displayed_count: int = 0
	for item in list:
		var title_str: String = item.get("title", "")
		var author_str: String = item.get("author", "")
		var tags_str: String = item.get("tags", "")
		var cat_str: String = item.get("category", "Nature")
		var folder_name: String = item.get("folder_name", "")
		var slug: String = item.get("slug", folder_name)

		# Category Filter
		if _current_category != "ALL":
			var cat_match: bool = (cat_str.to_lower() == _current_category.to_lower())
			var tag_match: bool = tags_str.to_lower().contains(_current_category.to_lower())
			var title_match: bool = title_str.to_lower().contains(_current_category.to_lower())
			if not (cat_match or tag_match or title_match):
				continue

		# Search Filter
		if not _search_query.is_empty():
			var combined: String = (title_str + " " + author_str + " " + tags_str + " " + cat_str).to_lower()
			if not combined.contains(_search_query):
				continue

		displayed_count += 1

		# Soundscape Card Container
		var card: PanelContainer = PanelContainer.new()
		card.custom_minimum_size = Vector2(250, 265)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Styled Card StyleBox
		var card_sb: StyleBoxFlat = StyleBoxFlat.new()
		card_sb.bg_color = pal["panel_bg"]
		card_sb.border_color = pal["panel_border"]
		card_sb.set_border_width_all(1)
		card_sb.set_corner_radius_all(8)
		card_sb.content_margin_left = 12
		card_sb.content_margin_right = 12
		card_sb.content_margin_top = 12
		card_sb.content_margin_bottom = 12
		card.add_theme_stylebox_override("panel", card_sb)

		var card_vbox: VBoxContainer = VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 6)
		card.add_child(card_vbox)

		# Cover Image
		var cover_rect: TextureRect = TextureRect.new()
		cover_rect.custom_minimum_size = Vector2(220, 110)
		cover_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cover_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		cover_rect.clip_contents = true

		var cover_loaded: bool = false
		var cov_path: String = item.get("cover_path", "")
		if cov_path.is_empty():
			cov_path = folder_name
		if not cov_path.is_empty():
			var img_tex: ImageTexture = LibraryManager.load_soundscape_cover_texture(cov_path)
			if img_tex != null:
				cover_rect.texture = img_tex
				cover_loaded = true

		if not cover_loaded:
			cover_rect.texture = load("res://assets/icons/library.svg")
			cover_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			cover_rect.modulate = pal["primary"]

		card_vbox.add_child(cover_rect)

		# Title
		var title_lbl: Label = Label.new()
		title_lbl.text = title_str
		title_lbl.add_theme_font_size_override("font_size", 13)
		title_lbl.add_theme_color_override("font_color", pal["primary"])
		title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		card_vbox.add_child(title_lbl)

		# Author, Category & Meta Info
		var meta_lbl: Label = Label.new()
		var track_count: int = item.get("track_count", 0)
		meta_lbl.text = "By %s • %s • %d Tracks" % [author_str if not author_str.is_empty() else "Unknown", cat_str, track_count]
		meta_lbl.add_theme_font_size_override("font_size", 10)
		meta_lbl.add_theme_color_override("font_color", pal["text_dim"])
		card_vbox.add_child(meta_lbl)

		var spacer: Control = Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card_vbox.add_child(spacer)

		# Button Row
		var btn_row: HBoxContainer = HBoxContainer.new()
		btn_row.add_theme_constant_override("separation", 6)
		card_vbox.add_child(btn_row)

		# 1. Load Project Button
		var btn_load: Button = Button.new()
		btn_load.text = LocalizationData.tr_key("BTN_LOAD_PROJECT")
		btn_load.icon = load("res://assets/icons/play.svg")
		btn_load.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_load.custom_minimum_size = Vector2(0, 32)
		btn_load.add_theme_constant_override("h_separation", 6)
		btn_load.add_theme_font_size_override("font_size", 11)
		btn_load.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_load.pressed.connect(func(): _load_soundscape(item))
		btn_row.add_child(btn_load)

		# 2. Edit Soundscape Button (Title / Category / Author)
		var btn_edit: Button = Button.new()
		btn_edit.tooltip_text = LocalizationData.tr_key("TOOLTIP_EDIT_SOUNDSCAPE")
		btn_edit.icon = load("res://assets/icons/edit.svg")
		btn_edit.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_edit.custom_minimum_size = Vector2(32, 32)
		btn_edit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_edit.pressed.connect(func(): _prompt_edit_soundscape(item))
		btn_row.add_child(btn_edit)

		# 3. Change Cover Button
		var btn_cov: Button = Button.new()
		btn_cov.tooltip_text = LocalizationData.tr_key("TOOLTIP_CHANGE_COVER")
		btn_cov.icon = load("res://assets/icons/image.svg")
		btn_cov.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_cov.custom_minimum_size = Vector2(32, 32)
		btn_cov.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_cov.pressed.connect(func(): _prompt_change_cover(slug))
		btn_row.add_child(btn_cov)

		# 4. Delete Button
		var btn_del: Button = Button.new()
		btn_del.tooltip_text = LocalizationData.tr_key("TOOLTIP_DELETE_SOUNDSCAPE")
		btn_del.icon = load("res://assets/icons/trash.svg")
		btn_del.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_del.custom_minimum_size = Vector2(32, 32)
		btn_del.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_del.pressed.connect(func(): _delete_soundscape(item))
		btn_row.add_child(btn_del)

		items_container.add_child(card)

	if displayed_count == 0:
		var empty_lbl: Label = Label.new()
		empty_lbl.text = LocalizationData.tr_key("EMPTY_SOUNDSCAPES_DESC")
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 12)
		empty_lbl.add_theme_color_override("font_color", pal["text_dim"])
		items_container.add_child(empty_lbl)

func _load_soundscape(item: Dictionary) -> void:
	var path: String = item.get("path", item.get("project_path", ""))
	if path.is_empty():
		return

	var project: SoundscapeData.SoundscapeProject = LibraryManager.load_soundscape(path)
	if project:
		soundscape_loaded.emit(project)

func _prompt_change_cover(slug: String) -> void:
	_selected_slug_for_cover = slug
	if cover_file_dialog:
		cover_file_dialog.title = LocalizationData.tr_key("DLG_COVER_TITLE")
		ThemeManager.apply_theme(cover_file_dialog, ThemeManager.current_theme)
		cover_file_dialog.popup_centered(Vector2i(650, 480))

func _on_cover_file_selected(file_path: String) -> void:
	if _selected_slug_for_cover.is_empty() or file_path.is_empty():
		return
	LibraryManager.set_soundscape_cover(_selected_slug_for_cover, file_path)
	refresh_library()

func _delete_soundscape(item: Dictionary) -> void:
	var folder_name: String = item.get("folder_name", item.get("slug", ""))
	if folder_name.is_empty():
		return

	LibraryManager.delete_soundscape(folder_name)
	refresh_library()
