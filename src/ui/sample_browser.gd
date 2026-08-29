class_name SampleBrowser
extends PanelContainer

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

signal sample_added_to_project(sample_name: String, sample_path: String)

@onready var search_edit: LineEdit = $VBox/TopBar/SearchEdit if has_node("VBox/TopBar/SearchEdit") else null
@onready var btn_import: Button = $VBox/TopBar/BtnImportSample if has_node("VBox/TopBar/BtnImportSample") else null
@onready var btn_refresh: Button = $VBox/TopBar/BtnRefresh if has_node("VBox/TopBar/BtnRefresh") else null
@onready var category_hbox: HBoxContainer = $VBox/CategoryHBox if has_node("VBox/CategoryHBox") else null
@onready var items_container: VBoxContainer = $VBox/Scroll/ItemsVBox if has_node("VBox/Scroll/ItemsVBox") else null
@onready var import_dialog: FileDialog = $ImportFileDialog if has_node("ImportFileDialog") else null
@onready var preview_player: AudioStreamPlayer = $PreviewPlayer if has_node("PreviewPlayer") else null

var _samples: Array[Dictionary] = [] # Array of {"name": str, "path": str, "category": str, "icon": str, "color_hex": str}
var _current_category: String = "ALL"
var _currently_playing_path: String = ""
var _categories: Array[String] = ["ALL", "Weather", "Nature", "Elements", "Ambient", "FX", "Music", "Voices", "Custom"]

const DEFAULT_CATEGORIES: Array[String] = ["ALL", "Weather", "Nature", "Elements", "Ambient", "FX", "Music", "Voices", "Custom"]
const CATEGORIES_FILE: String = "user://sample_categories.json"
const METADATA_FILE: String = "user://sample_metadata.json"

const AVAILABLE_ICONS: Array[String] = [
	"volume", "fire", "water", "birds", "wind", "rain", "bell", "steps", "music", "fx", "voice"
]

const ICON_LABELS: Dictionary = {
	"volume": "🔊 Default / Volume",
	"fire": "🔥 Fire / Campfire",
	"water": "💧 Water / Stream",
	"birds": "🐦 Birds / Wildlife",
	"wind": "💨 Wind / Breeze",
	"rain": "🌧️ Rain / Storm",
	"bell": "🔔 Bell / Chime",
	"steps": "👣 Footsteps",
	"music": "🎵 Music / Melody",
	"fx": "✨ Sound FX",
	"voice": "🗣️ Voice / Speech"
}

const PRESET_COLORS: Array[String] = [
	"#00e5ff", "#00e676", "#ff9100", "#ff1744", "#d500f9", "#2979ff", "#ffd600", "#f50057"
]

# Modals
var _edit_dialog: Window = null
var _add_cat_dialog: Window = null

func _ready() -> void:
	if preview_player == null:
		preview_player = AudioStreamPlayer.new()
		preview_player.name = "PreviewPlayer"
		add_child(preview_player)
		preview_player.finished.connect(_on_preview_finished)

	if btn_refresh:
		btn_refresh.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_refresh.pressed.connect(scan_samples)

	if btn_import:
		btn_import.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_import.pressed.connect(_on_import_pressed)

	if import_dialog:
		import_dialog.files_selected.connect(_on_files_imported)

	if search_edit:
		search_edit.placeholder_text = "🔍 Search samples by name, category, or sound icon..."
		search_edit.text_changed.connect(func(_t: String): _filter_items())

	_load_categories()
	_setup_category_filters()
	scan_samples()

func _load_categories() -> void:
	_categories = DEFAULT_CATEGORIES.duplicate()
	if FileAccess.file_exists(CATEGORIES_FILE):
		var file: FileAccess = FileAccess.open(CATEGORIES_FILE, FileAccess.READ)
		if file:
			var json: JSON = JSON.new()
			if json.parse(file.get_as_text()) == OK and json.data is Array:
				var loaded: Array = json.data
				for cat in loaded:
					var cat_str: String = str(cat).strip_edges()
					if not cat_str.is_empty() and not _categories.has(cat_str):
						_categories.append(cat_str)
			file.close()

func _save_categories() -> void:
	var file: FileAccess = FileAccess.open(CATEGORIES_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_categories, "\t"))
		file.close()

func _load_metadata() -> Dictionary:
	var meta: Dictionary = {}
	if FileAccess.file_exists(METADATA_FILE):
		var file: FileAccess = FileAccess.open(METADATA_FILE, FileAccess.READ)
		if file:
			var json: JSON = JSON.new()
			if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
				meta = json.data
			file.close()
	return meta

func _save_metadata(meta: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(METADATA_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(meta, "\t"))
		file.close()

func _setup_category_filters() -> void:
	if category_hbox == null:
		return
	for child in category_hbox.get_children():
		child.queue_free()

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
			_filter_items()
		)
		category_hbox.add_child(btn)

	# + Add Category Button
	var btn_add_cat: Button = Button.new()
	btn_add_cat.text = "➕ Add Category"
	btn_add_cat.tooltip_text = "Create a new custom category"
	btn_add_cat.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_add_cat.add_theme_font_size_override("font_size", 10)
	btn_add_cat.pressed.connect(_prompt_add_category)
	category_hbox.add_child(btn_add_cat)

	_update_category_buttons()

func _prompt_add_category() -> void:
	if _add_cat_dialog and is_instance_valid(_add_cat_dialog):
		_add_cat_dialog.queue_free()

	_add_cat_dialog = Window.new()
	_add_cat_dialog.title = "➕ Add Custom Category"
	_add_cat_dialog.size = Vector2i(380, 160)
	_add_cat_dialog.exclusive = true
	_add_cat_dialog.wrap_controls = true
	_add_cat_dialog.transient = true
	_add_cat_dialog.close_requested.connect(_add_cat_dialog.queue_free)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_add_cat_dialog.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var lbl: Label = Label.new()
	lbl.text = "Enter New Category Name:"
	lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl)

	var edit: LineEdit = LineEdit.new()
	edit.placeholder_text = "e.g. Atmosphere, Animals, Sci-Fi..."
	edit.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(edit)

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	var btn_cancel: Button = Button.new()
	btn_cancel.text = "Cancel"
	btn_cancel.pressed.connect(_add_cat_dialog.queue_free)
	btn_row.add_child(btn_cancel)

	var btn_ok: Button = Button.new()
	btn_ok.text = "Create Category"
	btn_ok.pressed.connect(func():
		var val: String = edit.text.strip_edges().capitalize()
		if not val.is_empty() and not _categories.has(val):
			_categories.append(val)
			_save_categories()
			_current_category = val
			_setup_category_filters()
			_filter_items()
		_add_cat_dialog.queue_free()
	)
	btn_row.add_child(btn_ok)

	ThemeManager.apply_theme(_add_cat_dialog, ThemeManager.current_theme)
	add_child(_add_cat_dialog)
	_add_cat_dialog.popup_centered()

func _update_category_buttons() -> void:
	if category_hbox == null: return
	var pal: Dictionary = ThemeManager.get_palette()
	for child in category_hbox.get_children():
		if child is Button and child.text != "➕ Add Category":
			var active: bool = (child.text == _current_category)
			child.button_pressed = active
			if active:
				child.modulate = Color(1.3, 1.3, 1.3)
				child.add_theme_color_override("font_color", pal["primary"])
			else:
				child.modulate = Color(1.0, 1.0, 1.0)
				child.add_theme_color_override("font_color", pal["text_dim"])

func _on_import_pressed() -> void:
	if import_dialog:
		ThemeManager.apply_theme(import_dialog, ThemeManager.current_theme)
		import_dialog.popup_centered(Vector2i(750, 480))

func _on_files_imported(paths: PackedStringArray) -> void:
	var samples_dir: String = OS.get_user_data_dir() + "/samples"
	if not DirAccess.dir_exists_absolute(samples_dir):
		DirAccess.make_dir_recursive_absolute(samples_dir)

	for p in paths:
		var file_name: String = p.get_file()
		var dest_path: String = samples_dir + "/" + file_name
		DirAccess.copy_absolute(p, dest_path)

	scan_samples()

func scan_samples() -> void:
	_samples.clear()
	var metadata: Dictionary = _load_metadata()
	
	# 1. Scan user://samples/ directory
	var samples_path: String = OS.get_user_data_dir() + "/samples"
	_scan_dir_for_audio(samples_path, "Custom", metadata)

	# 2. Scan user://library/ stems
	var lib_path: String = OS.get_user_data_dir() + "/library"
	var dir: DirAccess = DirAccess.open(lib_path)
	if dir:
		dir.list_dir_begin()
		var entry: String = dir.get_next()
		while not entry.is_empty():
			if dir.current_is_dir() and not entry.begins_with("."):
				_scan_dir_for_audio(lib_path + "/" + entry, entry.capitalize(), metadata)
			entry = dir.get_next()
		dir.list_dir_end()

	_filter_items()

func _scan_dir_for_audio(dir_path: String, category_name: String, metadata: Dictionary) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null: return
	dir.list_dir_begin()
	var file_entry: String = dir.get_next()
	while not file_entry.is_empty():
		var full_item_path: String = dir_path + "/" + file_entry
		if dir.current_is_dir():
			if not file_entry.begins_with("."):
				_scan_dir_for_audio(full_item_path, category_name, metadata)
		else:
			var lower: String = file_entry.to_lower()
			if lower.ends_with(".ogg") or lower.ends_with(".mp3") or lower.ends_with(".wav") or lower.ends_with(".flac"):
				var already_exists: bool = false
				for existing in _samples:
					if existing["path"] == full_item_path:
						already_exists = true
						break
				if not already_exists:
					var sample_name: String = file_entry.get_basename().replace("_", " ").capitalize()
					var icon_key: String = _detect_icon(sample_name)
					var cat: String = category_name
					var col_hex: String = "#00e5ff"

					# Check user custom metadata overrides
					if metadata.has(full_item_path):
						var m: Dictionary = metadata[full_item_path]
						if m.has("name"): sample_name = m["name"]
						if m.has("category"): cat = m["category"]
						if m.has("icon"): icon_key = m["icon"]
						if m.has("color_hex"): col_hex = m["color_hex"]

					_samples.append({
						"name": sample_name,
						"path": full_item_path,
						"category": cat,
						"icon": icon_key,
						"color_hex": col_hex
					})
		file_entry = dir.get_next()
	dir.list_dir_end()

func _detect_icon(name_str: String) -> String:
	var n: String = name_str.to_lower()
	if "rain" in n or "storm" in n or "thunder" in n or "shower" in n: return "rain"
	if "bird" in n or "owl" in n or "forest" in n or "cricket" in n: return "birds"
	if "fire" in n or "campfire" in n or "flame" in n or "torch" in n: return "fire"
	if "wind" in n or "breeze" in n or "air" in n or "gust" in n: return "wind"
	if "water" in n or "river" in n or "stream" in n or "sea" in n or "wave" in n: return "water"
	if "bell" in n or "chime" in n or "clock" in n: return "bell"
	if "step" in n or "foot" in n or "walk" in n: return "steps"
	if "voice" in n or "whisper" in n or "talk" in n or "chant" in n: return "voice"
	if "music" in n or "melody" in n or "piano" in n or "harp" in n or "guitar" in n: return "music"
	return "volume"

func _filter_items() -> void:
	if items_container == null:
		return

	for child in items_container.get_children():
		child.queue_free()

	var query: String = search_edit.text.strip_edges().to_lower() if search_edit else ""

	var filtered: Array[Dictionary] = []
	for s in _samples:
		if _current_category != "ALL":
			var cat_lower: String = s["category"].to_lower()
			var target_lower: String = _current_category.to_lower()
			if not (target_lower in cat_lower or s["icon"] == target_lower):
				continue

		if not query.is_empty():
			var name_match: bool = s["name"].to_lower().contains(query)
			var cat_match: bool = s["category"].to_lower().contains(query)
			var icon_match: bool = s["icon"].to_lower().contains(query)
			if not (name_match or cat_match or icon_match):
				continue

		filtered.append(s)

	if filtered.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No audio samples match the current filter. Click '📂 Import Audio...' or drag audio files here!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", ThemeManager.get_palette()["text_dim"])
		items_container.add_child(empty_lbl)
		return

	for s in filtered:
		var row: PanelContainer = _create_sample_row(s)
		items_container.add_child(row)

func _create_sample_row(s: Dictionary) -> PanelContainer:
	var row: PanelContainer = PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 36)
	
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	row.add_child(hbox)

	# Sound Icon with custom color accent
	var icon_tex: Texture2D = ThemeManager.get_sound_icon(s.get("icon", "volume"))
	if icon_tex:
		var icon_rect: TextureRect = TextureRect.new()
		icon_rect.texture = icon_tex
		icon_rect.custom_minimum_size = Vector2(20, 20)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var c_hex: String = s.get("color_hex", "#00e5ff")
		icon_rect.modulate = Color.from_string(c_hex, Color.CYAN)
		hbox.add_child(icon_rect)

	# Name
	var lbl_name: Label = Label.new()
	lbl_name.text = s["name"]
	lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_name.add_theme_font_size_override("font_size", 11)
	hbox.add_child(lbl_name)

	# Category pill
	var lbl_cat: Label = Label.new()
	lbl_cat.text = "[ " + s["category"] + " ]"
	lbl_cat.add_theme_font_size_override("font_size", 10)
	lbl_cat.add_theme_color_override("font_color", ThemeManager.get_palette()["text_dim"])
	hbox.add_child(lbl_cat)

	# Edit button (✏️)
	var btn_edit: Button = Button.new()
	btn_edit.text = "✏️ Edit"
	btn_edit.tooltip_text = "Edit sound name, icon, category, and accent color"
	btn_edit.custom_minimum_size = Vector2(65, 26)
	btn_edit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_edit.add_theme_font_size_override("font_size", 10)
	btn_edit.pressed.connect(func(): _open_sample_editor(s))
	hbox.add_child(btn_edit)

	# Audition Play / Stop button (Icon only, no "Audition" text)
	var btn_play: Button = Button.new()
	var is_playing: bool = (_currently_playing_path == s["path"] and preview_player and preview_player.playing)
	btn_play.text = "⏹" if is_playing else "▶"
	btn_play.tooltip_text = "Stop Preview" if is_playing else "Play Audio Preview"
	btn_play.custom_minimum_size = Vector2(36, 26)
	btn_play.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_play.add_theme_font_size_override("font_size", 12)
	btn_play.pressed.connect(func():
		_toggle_audition(s["path"])
	)
	hbox.add_child(btn_play)

	# Add to Soundscape button
	var btn_add: Button = Button.new()
	btn_add.text = "➕ Add to Studio"
	btn_add.custom_minimum_size = Vector2(105, 26)
	btn_add.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_add.add_theme_font_size_override("font_size", 10)
	btn_add.pressed.connect(func():
		sample_added_to_project.emit(s["name"], s["path"])
	)
	hbox.add_child(btn_add)

	# Drag & drop source configuration
	row.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Click on row
			pass
	)

	return row

func _get_drag_data_for_sample(s: Dictionary) -> Variant:
	var drag_data: Dictionary = {
		"type": "sample",
		"name": s["name"],
		"path": s["path"],
		"category": s["category"],
		"icon": s.get("icon", "volume"),
		"color_hex": s.get("color_hex", "#00e5ff")
	}

	var preview: PanelContainer = PanelContainer.new()
	var pal: Dictionary = ThemeManager.get_palette()
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = pal["panel_bg"]
	sb.set_border_width_all(1)
	sb.border_color = pal["primary"]
	sb.set_corner_radius_all(6)
	preview.add_theme_stylebox_override("panel", sb)

	var hbox: HBoxContainer = HBoxContainer.new()
	preview.add_child(hbox)

	var lbl: Label = Label.new()
	lbl.text = "🎵 " + s["name"]
	lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(lbl)

	set_drag_preview(preview)
	return drag_data

func _open_sample_editor(s: Dictionary) -> void:
	if _edit_dialog and is_instance_valid(_edit_dialog):
		_edit_dialog.queue_free()

	_edit_dialog = Window.new()
	_edit_dialog.title = "✏️ Edit Sound: " + s["name"]
	_edit_dialog.size = Vector2i(440, 360)
	_edit_dialog.exclusive = true
	_edit_dialog.wrap_controls = true
	_edit_dialog.transient = true
	_edit_dialog.close_requested.connect(_edit_dialog.queue_free)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_edit_dialog.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Name Edit
	var lbl_name: Label = Label.new()
	lbl_name.text = "Sound Display Name:"
	lbl_name.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_name)

	var name_edit: LineEdit = LineEdit.new()
	name_edit.text = s["name"]
	name_edit.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(name_edit)

	# Category Dropdown
	var lbl_cat: Label = Label.new()
	lbl_cat.text = "Category:"
	lbl_cat.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_cat)

	var cat_opt: OptionButton = OptionButton.new()
	cat_opt.custom_minimum_size = Vector2(0, 30)
	var cat_list: Array[String] = []
	for c in _categories:
		if c != "ALL": cat_list.append(c)
	for i in range(cat_list.size()):
		cat_opt.add_item(cat_list[i], i)
		if cat_list[i] == s["category"]:
			cat_opt.select(i)
	vbox.add_child(cat_opt)

	# Radar Icon Selector
	var lbl_icon: Label = Label.new()
	lbl_icon.text = "Radar Sound Icon:"
	lbl_icon.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_icon)

	var icon_opt: OptionButton = OptionButton.new()
	icon_opt.custom_minimum_size = Vector2(0, 30)
	for i in range(AVAILABLE_ICONS.size()):
		var ic_key: String = AVAILABLE_ICONS[i]
		var ic_tex: Texture2D = ThemeManager.get_sound_icon(ic_key)
		var label_str: String = ICON_LABELS.get(ic_key, ic_key.capitalize())
		icon_opt.add_icon_item(ic_tex, label_str, i)
		if ic_key == s.get("icon", "volume"):
			icon_opt.select(i)
	vbox.add_child(icon_opt)

	# Default Accent Color
	var lbl_color: Label = Label.new()
	lbl_color.text = "Default Accent Color:"
	lbl_color.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_color)

	var color_hbox: HBoxContainer = HBoxContainer.new()
	color_hbox.add_theme_constant_override("separation", 6)
	vbox.add_child(color_hbox)

	var selected_col: String = s.get("color_hex", "#00e5ff")
	var color_btns: Array[Button] = []
	for hex in PRESET_COLORS:
		var c_btn: Button = Button.new()
		c_btn.custom_minimum_size = Vector2(28, 28)
		c_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var rect: ColorRect = ColorRect.new()
		rect.color = Color.from_string(hex, Color.CYAN)
		rect.custom_minimum_size = Vector2(16, 16)
		rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c_btn.add_child(rect)

		var this_hex: String = hex
		c_btn.pressed.connect(func():
			selected_col = this_hex
			for b in color_btns:
				b.modulate = Color(1.0, 1.0, 1.0)
			c_btn.modulate = Color(1.4, 1.4, 1.4)
		)
		if hex == selected_col:
			c_btn.modulate = Color(1.4, 1.4, 1.4)
		color_hbox.add_child(c_btn)
		color_btns.append(c_btn)

	# Dialog Buttons
	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	var btn_cancel: Button = Button.new()
	btn_cancel.text = "Cancel"
	btn_cancel.pressed.connect(_edit_dialog.queue_free)
	btn_row.add_child(btn_cancel)

	var btn_save: Button = Button.new()
	btn_save.text = "💾 Save Changes"
	btn_save.pressed.connect(func():
		var new_name: String = name_edit.text.strip_edges()
		if new_name.is_empty(): new_name = s["name"]
		var new_cat: String = cat_opt.get_item_text(cat_opt.selected)
		var new_icon: String = AVAILABLE_ICONS[icon_opt.selected] if icon_opt.selected >= 0 and icon_opt.selected < AVAILABLE_ICONS.size() else "volume"

		s["name"] = new_name
		s["category"] = new_cat
		s["icon"] = new_icon
		s["color_hex"] = selected_col

		var meta: Dictionary = _load_metadata()
		meta[s["path"]] = {
			"name": new_name,
			"category": new_cat,
			"icon": new_icon,
			"color_hex": selected_col
		}
		_save_metadata(meta)
		_filter_items()
		_edit_dialog.queue_free()
	)
	btn_row.add_child(btn_save)

	ThemeManager.apply_theme(_edit_dialog, ThemeManager.current_theme)
	add_child(_edit_dialog)
	_edit_dialog.popup_centered()

func _toggle_audition(file_path: String) -> void:
	if preview_player == null:
		return
	if _currently_playing_path == file_path and preview_player.playing:
		preview_player.stop()
		_currently_playing_path = ""
	else:
		var stream: AudioStream = AudioImporter.load_audio_stream(file_path)
		if stream:
			_currently_playing_path = file_path
			preview_player.stream = stream
			preview_player.play()
	_filter_items()

func _on_preview_finished() -> void:
	_currently_playing_path = ""
	_filter_items()

# Drag and drop support for Sample Browser
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is PackedStringArray or data is Array:
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is PackedStringArray or data is Array:
		var paths: PackedStringArray = PackedStringArray()
		for item in data:
			var path_str: String = str(item)
			var lower: String = path_str.to_lower()
			if lower.ends_with(".wav") or lower.ends_with(".mp3") or lower.ends_with(".ogg") or lower.ends_with(".flac"):
				paths.append(path_str)
		if not paths.is_empty():
			_on_files_imported(paths)
