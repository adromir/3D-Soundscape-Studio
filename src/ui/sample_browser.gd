class_name SampleBrowser
extends PanelContainer

# Author: Adromir
# Repository: https://github.com/adromir

signal sample_added_to_project(sample_name: String, sample_path: String)

@onready var search_edit: LineEdit = $VBox/TopBar/SearchEdit
@onready var btn_import: Button = $VBox/TopBar/BtnImportSample
@onready var btn_refresh: Button = $VBox/TopBar/BtnRefresh
@onready var category_hbox: HBoxContainer = $VBox/CategoryHBox
@onready var items_container: VBoxContainer = $VBox/Scroll/ItemsVBox
@onready var import_dialog: FileDialog = $ImportFileDialog if has_node("ImportFileDialog") else null
@onready var preview_player: AudioStreamPlayer = $PreviewPlayer if has_node("PreviewPlayer") else null

var _samples: Array[Dictionary] = [] # Array of {"name": str, "path": str, "category": str, "icon": str}
var _current_category: String = "ALL"
var _currently_playing_path: String = ""

const CATEGORIES: Array[String] = ["ALL", "Weather", "Nature", "Elements", "Ambient", "FX", "Music", "Voices"]

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
		search_edit.text_changed.connect(func(_t: String): _filter_items())

	_setup_category_filters()
	scan_samples()

func _setup_category_filters() -> void:
	if category_hbox == null:
		return
	for child in category_hbox.get_children():
		child.queue_free()

	for cat in CATEGORIES:
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

func _update_category_buttons() -> void:
	if category_hbox == null: return
	var pal: Dictionary = ThemeManager.get_palette()
	for child in category_hbox.get_children():
		if child is Button:
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
	
	# 1. Scan user://samples/ directory
	var samples_path: String = OS.get_user_data_dir() + "/samples"
	_scan_dir_for_audio(samples_path, "Custom")

	# 2. Scan user://library/ stems
	var lib_path: String = OS.get_user_data_dir() + "/library"
	var dir: DirAccess = DirAccess.open(lib_path)
	if dir:
		dir.list_dir_begin()
		var entry: String = dir.get_next()
		while not entry.is_empty():
			if dir.current_is_dir() and not entry.begins_with("."):
				_scan_dir_for_audio(lib_path + "/" + entry, entry.capitalize())
			entry = dir.get_next()
		dir.list_dir_end()

	_filter_items()

func _scan_dir_for_audio(dir_path: String, category_name: String) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null: return
	dir.list_dir_begin()
	var file_entry: String = dir.get_next()
	while not file_entry.is_empty():
		var full_item_path: String = dir_path + "/" + file_entry
		if dir.current_is_dir():
			if not file_entry.begins_with("."):
				_scan_dir_for_audio(full_item_path, category_name)
		else:
			var lower: String = file_entry.to_lower()
			if lower.ends_with(".ogg") or lower.ends_with(".mp3") or lower.ends_with(".wav"):
				# Avoid duplicate paths
				var already_exists: bool = false
				for existing in _samples:
					if existing["path"] == full_item_path:
						already_exists = true
						break
				if not already_exists:
					var sample_name: String = file_entry.get_basename().replace("_", " ").capitalize()
					var icon_key: String = _detect_icon(sample_name)
					_samples.append({
						"name": sample_name,
						"path": full_item_path,
						"category": category_name,
						"icon": icon_key
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

		if not query.is_empty() and not s["name"].to_lower().contains(query) and not s["category"].to_lower().contains(query):
			continue

		filtered.append(s)

	if filtered.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No individual audio samples found. Click '📂 Import Audio...' to add your sound effects!"
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
	row.custom_minimum_size = Vector2(0, 34)
	
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	row.add_child(hbox)

	# Category icon
	var icon_tex: Texture2D = _load_svg_icon(s.get("icon", "volume"))
	if icon_tex:
		var icon_rect: TextureRect = TextureRect.new()
		icon_rect.texture = icon_tex
		icon_rect.custom_minimum_size = Vector2(18, 18)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
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

	# Audition Play / Stop button
	var btn_play: Button = Button.new()
	var is_playing: bool = (_currently_playing_path == s["path"] and preview_player and preview_player.playing)
	btn_play.text = "⏹ Stop" if is_playing else "▶ Audition"
	btn_play.custom_minimum_size = Vector2(85, 22)
	btn_play.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_play.add_theme_font_size_override("font_size", 10)
	btn_play.pressed.connect(func():
		_toggle_audition(s["path"])
	)
	hbox.add_child(btn_play)

	# Add to Soundscape button
	var btn_add: Button = Button.new()
	btn_add.text = "+ Add to Studio"
	btn_add.custom_minimum_size = Vector2(105, 22)
	btn_add.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_add.add_theme_font_size_override("font_size", 10)
	btn_add.pressed.connect(func():
		sample_added_to_project.emit(s["name"], s["path"])
	)
	hbox.add_child(btn_add)

	return row

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

func _load_svg_icon(icon_name: String) -> Texture2D:
	return ThemeManager.get_sound_icon(icon_name)
