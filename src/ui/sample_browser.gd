class_name SampleBrowser
extends PanelContainer

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio




signal sample_added_to_project(sample_name: String, sample_path: String)

@onready var search_edit: LineEdit = $VBox/TopBar/SearchBox/SearchEdit if has_node("VBox/TopBar/SearchBox/SearchEdit") else ($VBox/TopBar/SearchEdit if has_node("VBox/TopBar/SearchEdit") else null)
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

static func get_categories_file() -> String:
	return AppPaths.get_sample_categories_file()

static func get_metadata_file() -> String:
	return AppPaths.get_sample_metadata_file()

const AVAILABLE_ICONS: Array[String] = [
	"volume", "fire", "water", "birds", "wind", "rain", "bell", "steps", "music", "fx", "voice"
]

const ICON_LABELS: Dictionary = {
	"volume": "Default / Volume",
	"fire": "Fire / Campfire",
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

const PRESET_COLORS: Array[String] = [
	"#00e5ff", "#00e676", "#ff9100", "#ff1744", "#d500f9", "#2979ff", "#ffd600", "#f50057"
]

# Mode Switch: 0 = Local, 1 = Freesound, 2 = AI Gen
enum BrowserMode { LOCAL, FREESOUND, AI_GEN }
var _current_mode: BrowserMode = BrowserMode.LOCAL

# Freesound client and state
var _freesound_client: FreesoundClient = null
var _freesound_results: Array[Dictionary] = []
var _is_freesound_searching: bool = false
var _freesound_search_status: String = ""
var _downloading_ids: Dictionary = {} # sound_id -> bool
var _downloaded_ids: Dictionary = {} # sound_id -> file_path

# AI Generation Engine and state
var _audiogen_engine: AudioGenEngine = null
var _ai_generated_history: Array[Dictionary] = []

# UI Nodes for Mode Switching & Online Filtering
var _mode_bar: HBoxContainer = null
var _btn_mode_local: Button = null
var _btn_mode_freesound: Button = null
var _btn_mode_ai_gen: Button = null
var _freesound_filter_bar: HBoxContainer = null
var _opt_license: OptionButton = null
var _opt_duration: OptionButton = null
var _btn_search_online: Button = null
var _quick_tags_bar: HBoxContainer = null

# AI Generator UI
var _ai_gen_panel: PanelContainer = null
var _ai_prompt_edit: LineEdit = null
var _ai_dur_slider: HSlider = null
var _ai_dur_label: Label = null
var _ai_btn_generate: Button = null
var _ai_progress_bar: ProgressBar = null
var _ai_status_label: Label = null

# Modals
var _edit_dialog: Window = null
var _add_cat_dialog: Window = null

func _ready() -> void:
	if preview_player == null:
		preview_player = AudioStreamPlayer.new()
		preview_player.name = "PreviewPlayer"
		add_child(preview_player)
		preview_player.finished.connect(_on_preview_finished)

	_freesound_client = FreesoundClient.new()
	_freesound_client.name = "FreesoundClient"
	add_child(_freesound_client)
	_freesound_client.search_started.connect(_on_freesound_search_started)
	_freesound_client.search_completed.connect(_on_freesound_search_completed)
	_freesound_client.search_failed.connect(_on_freesound_search_failed)
	_freesound_client.download_completed.connect(_on_freesound_download_completed)
	_freesound_client.download_failed.connect(_on_freesound_download_failed)

	_audiogen_engine = AudioGenEngine.new()
	_audiogen_engine.name = "AudioGenEngine"
	add_child(_audiogen_engine)
	_audiogen_engine.generation_started.connect(_on_ai_generation_started)
	_audiogen_engine.generation_progress.connect(_on_ai_generation_progress)
	_audiogen_engine.generation_completed.connect(_on_ai_generation_completed)
	_audiogen_engine.generation_failed.connect(_on_ai_generation_failed)

	_setup_top_mode_controls()

	if btn_refresh:
		btn_refresh.icon = load("res://assets/icons/reset.svg")
		btn_refresh.expand_icon = true
		btn_refresh.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_refresh.pressed.connect(scan_samples)

	if btn_import:
		btn_import.icon = load("res://assets/icons/plus.svg")
		btn_import.expand_icon = true
		btn_import.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_import.pressed.connect(_on_import_pressed)

	if import_dialog:
		import_dialog.files_selected.connect(_on_files_imported)

	if search_edit:
		search_edit.placeholder_text = "Search single audio stems & samples..."
		search_edit.text_submitted.connect(func(_t: String):
			if _current_mode == BrowserMode.FREESOUND:
				_execute_freesound_search()
			else:
				_filter_items()
		)
		search_edit.text_changed.connect(func(_t: String):
			if _current_mode == BrowserMode.LOCAL:
				_filter_items()
		)

	_load_categories()
	_setup_category_filters()
	scan_samples()
	update_localization()

func _setup_top_mode_controls() -> void:
	var vbox = get_node_or_null("VBox")
	if vbox == null:
		return

	# Insert Mode Bar at top (Index 0)
	_mode_bar = HBoxContainer.new()
	_mode_bar.name = "BrowserModeBar"
	_mode_bar.add_theme_constant_override("separation", 6)
	vbox.add_child(_mode_bar)
	vbox.move_child(_mode_bar, 0)

	_btn_mode_local = Button.new()
	_btn_mode_local.text = LocalizationData.tr_key("TAB_LOCAL_SAMPLES")
	_btn_mode_local.icon = load("res://assets/icons/samples.svg")
	_btn_mode_local.expand_icon = true
	_btn_mode_local.toggle_mode = true
	_btn_mode_local.button_pressed = true
	_btn_mode_local.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_mode_local.custom_minimum_size = Vector2(140, 28)
	_btn_mode_local.add_theme_font_size_override("font_size", 11)
	_btn_mode_local.pressed.connect(func(): _switch_browser_mode(BrowserMode.LOCAL))
	_mode_bar.add_child(_btn_mode_local)

	_btn_mode_freesound = Button.new()
	_btn_mode_freesound.text = LocalizationData.tr_key("TAB_FREESOUND")
	_btn_mode_freesound.icon = load("res://assets/icons/volume.svg")
	_btn_mode_freesound.expand_icon = true
	_btn_mode_freesound.toggle_mode = true
	_btn_mode_freesound.button_pressed = false
	_btn_mode_freesound.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_mode_freesound.custom_minimum_size = Vector2(170, 28)
	_btn_mode_freesound.add_theme_font_size_override("font_size", 11)
	_btn_mode_freesound.pressed.connect(func(): _switch_browser_mode(BrowserMode.FREESOUND))
	_mode_bar.add_child(_btn_mode_freesound)

	_btn_mode_ai_gen = Button.new()
	_btn_mode_ai_gen.text = LocalizationData.tr_key("TAB_AI_GEN")
	_btn_mode_ai_gen.toggle_mode = true
	_btn_mode_ai_gen.button_pressed = false
	_btn_mode_ai_gen.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_mode_ai_gen.custom_minimum_size = Vector2(230, 28)
	_btn_mode_ai_gen.add_theme_font_size_override("font_size", 11)
	_btn_mode_ai_gen.pressed.connect(func(): _switch_browser_mode(BrowserMode.AI_GEN))
	_mode_bar.add_child(_btn_mode_ai_gen)

	# Quick Tags Bar for Freesound
	_quick_tags_bar = HBoxContainer.new()
	_quick_tags_bar.name = "QuickTagsBar"
	_quick_tags_bar.add_theme_constant_override("separation", 6)
	_quick_tags_bar.visible = false
	vbox.add_child(_quick_tags_bar)
	vbox.move_child(_quick_tags_bar, 2)

	var quick_tags: Array[String] = ["Rain", "Thunder", "Campfire", "Birds", "River", "Wind", "Footsteps", "Forest", "Bell", "Clock"]
	for qtag in quick_tags:
		var q_btn: Button = Button.new()
		q_btn.text = "#" + qtag
		q_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		q_btn.add_theme_font_size_override("font_size", 10)
		var this_tag: String = qtag
		q_btn.pressed.connect(func():
			if search_edit:
				search_edit.text = this_tag
			_execute_freesound_search()
		)
		_quick_tags_bar.add_child(q_btn)

	# Online Filter Bar (License & Duration)
	_freesound_filter_bar = HBoxContainer.new()
	_freesound_filter_bar.name = "FreesoundFilterBar"
	_freesound_filter_bar.add_theme_constant_override("separation", 10)
	_freesound_filter_bar.visible = false
	vbox.add_child(_freesound_filter_bar)
	vbox.move_child(_freesound_filter_bar, 3)

	var lbl_lic: Label = Label.new()
	lbl_lic.text = LocalizationData.tr_key("FILTER_LICENSE") + ":"
	lbl_lic.add_theme_font_size_override("font_size", 11)
	_freesound_filter_bar.add_child(lbl_lic)

	_opt_license = OptionButton.new()
	_opt_license.custom_minimum_size = Vector2(170, 26)
	_opt_license.add_theme_font_size_override("font_size", 10)
	_opt_license.add_item("CC0 (Public Domain)", 0)
	_opt_license.add_item("Attribution (CC-BY)", 1)
	_opt_license.add_item("All Licenses", 2)
	_opt_license.selected = 0
	_freesound_filter_bar.add_child(_opt_license)

	var lbl_dur: Label = Label.new()
	lbl_dur.text = LocalizationData.tr_key("FILTER_DURATION") + ":"
	lbl_dur.add_theme_font_size_override("font_size", 11)
	_freesound_filter_bar.add_child(lbl_dur)

	_opt_duration = OptionButton.new()
	_opt_duration.custom_minimum_size = Vector2(120, 26)
	_opt_duration.add_theme_font_size_override("font_size", 10)
	_opt_duration.add_item("Any (< 120s)", 0)
	_opt_duration.add_item("< 10s (Stinger)", 1)
	_opt_duration.add_item("10s - 30s", 2)
	_opt_duration.add_item("30s - 60s", 3)
	_opt_duration.add_item("> 60s (Loop)", 4)
	_opt_duration.selected = 0
	_freesound_filter_bar.add_child(_opt_duration)

	_btn_search_online = Button.new()
	_btn_search_online.text = LocalizationData.tr_key("BTN_SEARCH_ONLINE")
	_btn_search_online.icon = load("res://assets/icons/search.svg")
	_btn_search_online.expand_icon = true
	_btn_search_online.custom_minimum_size = Vector2(140, 26)
	_btn_search_online.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btn_search_online.add_theme_font_size_override("font_size", 10)
	_btn_search_online.pressed.connect(_execute_freesound_search)
	_freesound_filter_bar.add_child(_btn_search_online)

	var btn_key: Button = Button.new()
	btn_key.text = "API-Key"
	btn_key.custom_minimum_size = Vector2(90, 26)
	btn_key.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_key.add_theme_font_size_override("font_size", 10)
	btn_key.tooltip_text = "Configure Freesound.org API Token"
	btn_key.pressed.connect(func():
		_freesound_search_status = "API_KEY_REQUIRED"
		_filter_items()
	)
	_freesound_filter_bar.add_child(btn_key)

	# AI Generation Panel
	_ai_gen_panel = PanelContainer.new()
	_ai_gen_panel.name = "AIGenPanel"
	_ai_gen_panel.visible = false
	var ai_sb: StyleBoxFlat = StyleBoxFlat.new()
	ai_sb.bg_color = ThemeManager.get_palette()["btn_normal"]
	ai_sb.border_color = ThemeManager.get_palette()["panel_border"]
	ai_sb.set_border_width_all(1)
	ai_sb.set_corner_radius_all(8)
	ai_sb.content_margin_left = 12
	ai_sb.content_margin_right = 12
	ai_sb.content_margin_top = 10
	ai_sb.content_margin_bottom = 10
	_ai_gen_panel.add_theme_stylebox_override("panel", ai_sb)
	vbox.add_child(_ai_gen_panel)
	vbox.move_child(_ai_gen_panel, 4)

	var ai_vbox: VBoxContainer = VBoxContainer.new()
	ai_vbox.add_theme_constant_override("separation", 8)
	_ai_gen_panel.add_child(ai_vbox)

	var ai_row1: HBoxContainer = HBoxContainer.new()
	ai_row1.add_theme_constant_override("separation", 8)
	ai_vbox.add_child(ai_row1)

	_ai_prompt_edit = LineEdit.new()
	_ai_prompt_edit.placeholder_text = LocalizationData.tr_key("PROMPT_AI_GEN_PLACEHOLDER")
	_ai_prompt_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ai_prompt_edit.custom_minimum_size = Vector2(0, 28)
	_ai_prompt_edit.add_theme_font_size_override("font_size", 11)
	_ai_prompt_edit.text_submitted.connect(func(_t: String): _on_ai_generate_pressed())
	ai_row1.add_child(_ai_prompt_edit)

	_ai_dur_label = Label.new()
	_ai_dur_label.text = "5.0s"
	_ai_dur_label.add_theme_font_size_override("font_size", 10)
	ai_row1.add_child(_ai_dur_label)

	_ai_dur_slider = HSlider.new()
	_ai_dur_slider.min_value = 1.0
	_ai_dur_slider.max_value = 20.0
	_ai_dur_slider.step = 0.5
	_ai_dur_slider.value = 5.0
	_ai_dur_slider.custom_minimum_size = Vector2(80, 20)
	_ai_dur_slider.size_flags_vertical = 4
	_ai_dur_slider.value_changed.connect(func(v: float): if _ai_dur_label: _ai_dur_label.text = "%.1fs" % v)
	ai_row1.add_child(_ai_dur_slider)

	_ai_btn_generate = Button.new()
	_ai_btn_generate.text = LocalizationData.tr_key("BTN_GENERATE_AI_SOUND")
	_ai_btn_generate.custom_minimum_size = Vector2(170, 28)
	_ai_btn_generate.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_ai_btn_generate.add_theme_font_size_override("font_size", 11)
	_ai_btn_generate.pressed.connect(_on_ai_generate_pressed)
	ai_row1.add_child(_ai_btn_generate)

	var prompt_chips_row: HBoxContainer = HBoxContainer.new()
	prompt_chips_row.add_theme_constant_override("separation", 6)
	ai_vbox.add_child(prompt_chips_row)

	var ai_chips: Array[String] = [
		"Misty Forest Wind",
		"Deep Thunderclap",
		"Hearth Fireplace",
		"Ocean Shore Tide",
		"Sacred Temple Chime",
		"Shimmering Ambient Drone"
	]
	for chip in ai_chips:
		var c_btn: Button = Button.new()
		c_btn.text = chip
		c_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		c_btn.add_theme_font_size_override("font_size", 10)
		var c_txt: String = chip.strip_edges()
		c_btn.pressed.connect(func():
			if _ai_prompt_edit: _ai_prompt_edit.text = c_txt
		)
		prompt_chips_row.add_child(c_btn)

	_ai_progress_bar = ProgressBar.new()
	_ai_progress_bar.custom_minimum_size = Vector2(0, 8)
	_ai_progress_bar.max_value = 1.0
	_ai_progress_bar.value = 0.0
	_ai_progress_bar.show_percentage = false
	_ai_progress_bar.visible = false
	ai_vbox.add_child(_ai_progress_bar)

	var backend_label = Label.new()
	if _audiogen_engine and _audiogen_engine.backend == AudioGenEngine.BackendMode.PROCEDURAL_DSP:
		backend_label.text = "Backend: Offline Acoustic Synth (Procedural DSP)"
	else:
		backend_label.text = "Backend: Native audio.cpp Local Inference"
	backend_label.add_theme_font_size_override("font_size", 9)
	backend_label.add_theme_color_override("font_color", ThemeManager.get_palette()["text_dim"])
	backend_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ai_vbox.add_child(backend_label)

	_ai_status_label = Label.new()
	_ai_status_label.text = "Ready. Configure audio.cpp and GGUF model in Settings to use Neural Synthesis."
	_ai_status_label.add_theme_font_size_override("font_size", 9)
	_ai_status_label.add_theme_color_override("font_color", ThemeManager.get_palette()["text_dim"])
	ai_vbox.add_child(_ai_status_label)

func _switch_browser_mode(mode: BrowserMode) -> void:
	_current_mode = mode
	if _btn_mode_local: _btn_mode_local.button_pressed = (mode == BrowserMode.LOCAL)
	if _btn_mode_freesound: _btn_mode_freesound.button_pressed = (mode == BrowserMode.FREESOUND)
	if _btn_mode_ai_gen: _btn_mode_ai_gen.button_pressed = (mode == BrowserMode.AI_GEN)

	if category_hbox: category_hbox.visible = (mode == BrowserMode.LOCAL)
	if btn_import: btn_import.visible = (mode == BrowserMode.LOCAL)
	if btn_refresh: btn_refresh.visible = (mode == BrowserMode.LOCAL)

	if _quick_tags_bar: _quick_tags_bar.visible = (mode == BrowserMode.FREESOUND)
	if _freesound_filter_bar: _freesound_filter_bar.visible = (mode == BrowserMode.FREESOUND)
	if _ai_gen_panel: _ai_gen_panel.visible = (mode == BrowserMode.AI_GEN)

	if search_edit:
		search_edit.visible = (mode != BrowserMode.AI_GEN)
		if mode == BrowserMode.FREESOUND:
			search_edit.placeholder_text = LocalizationData.tr_key("SEARCH_FREESOUND_PLACEHOLDER")
		else:
			search_edit.placeholder_text = "Search single audio stems & samples..."

	if preview_player and preview_player.playing:
		preview_player.stop()
		_currently_playing_path = ""

	_filter_items()

func _execute_freesound_search() -> void:
	if _freesound_client == null or search_edit == null:
		return

	var q: String = search_edit.text.strip_edges()
	if q.is_empty():
		q = "ambient"

	var lic_mode: String = "cc0"
	if _opt_license:
		if _opt_license.selected == 1: lic_mode = "attribution"
		elif _opt_license.selected == 2: lic_mode = "all"

	var min_d: float = 0.0
	var max_d: float = 120.0
	if _opt_duration:
		match _opt_duration.selected:
			1: min_d = 0.1; max_d = 10.0
			2: min_d = 10.0; max_d = 30.0
			3: min_d = 30.0; max_d = 60.0
			4: min_d = 60.0; max_d = 300.0

	_freesound_client.search_sounds(q, lic_mode, min_d, max_d)

func _on_freesound_search_started() -> void:
	_is_freesound_searching = true
	_freesound_search_status = LocalizationData.tr_key("FREESOUND_SEARCHING")
	_filter_items()

func _on_freesound_search_completed(results: Array[Dictionary], _total: int) -> void:
	_is_freesound_searching = false
	_freesound_results = results
	_freesound_search_status = ""
	_filter_items()

func _on_freesound_search_failed(err_msg: String) -> void:
	_is_freesound_searching = false
	_freesound_results.clear()
	if err_msg == "API_KEY_REQUIRED" or "Invalid token" in err_msg or "401" in err_msg or "403" in err_msg:
		_freesound_search_status = "API_KEY_REQUIRED"
	else:
		_freesound_search_status = "Error searching Freesound.org: " + err_msg
	_filter_items()

func _on_freesound_download_completed(sound_id: int, file_path: String, metadata: Dictionary) -> void:
	_downloading_ids.erase(sound_id)
	_downloaded_ids[sound_id] = file_path
	scan_samples()

	# Show brief success feedback
	_filter_items()

func _on_freesound_download_failed(sound_id: int, err_msg: String) -> void:
	_downloading_ids.erase(sound_id)
	_filter_items()

func update_localization() -> void:
	if _btn_mode_local:
		_btn_mode_local.text = LocalizationData.tr_key("TAB_LOCAL_SAMPLES")
	if _btn_mode_freesound:
		_btn_mode_freesound.text = LocalizationData.tr_key("TAB_FREESOUND")
	if _btn_search_online:
		_btn_search_online.text = LocalizationData.tr_key("BTN_SEARCH_ONLINE")
	if btn_import:
		btn_import.text = LocalizationData.tr_key("BTN_IMPORT") if LocalizationData.tr_key("BTN_IMPORT") != "BTN_IMPORT" else "Import Audio..."
	if btn_refresh:
		btn_refresh.text = LocalizationData.tr_key("BTN_REFRESH") if LocalizationData.tr_key("BTN_REFRESH") != "BTN_REFRESH" else "Refresh"
	if search_edit:
		if _current_mode == BrowserMode.FREESOUND:
			search_edit.placeholder_text = LocalizationData.tr_key("SEARCH_FREESOUND_PLACEHOLDER")
		else:
			search_edit.placeholder_text = "Search single audio stems & samples..."

func _load_categories() -> void:
	_categories = DEFAULT_CATEGORIES.duplicate()
	if FileAccess.file_exists(get_categories_file()):
		var file: FileAccess = FileAccess.open(get_categories_file(), FileAccess.READ)
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
	var file: FileAccess = FileAccess.open(get_categories_file(), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_categories, "\t"))
		file.close()

func _load_metadata() -> Dictionary:
	var meta: Dictionary = {}
	if FileAccess.file_exists(get_metadata_file()):
		var file: FileAccess = FileAccess.open(get_metadata_file(), FileAccess.READ)
		if file:
			var json: JSON = JSON.new()
			if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
				meta = json.data
			file.close()
	return meta

func _save_metadata(meta: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(get_metadata_file(), FileAccess.WRITE)
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
	btn_add_cat.text = "Add Category"
	btn_add_cat.icon = load("res://assets/icons/plus.svg")
	btn_add_cat.expand_icon = true
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
	_add_cat_dialog.title = ""
	_add_cat_dialog.size = Vector2i(380, 160)
	_add_cat_dialog.exclusive = true
	_add_cat_dialog.wrap_controls = true
	_add_cat_dialog.transient = true
	_add_cat_dialog.borderless = true
	_add_cat_dialog.close_requested.connect(_add_cat_dialog.queue_free)

	var pal: Dictionary = ThemeManager.get_palette()
	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_add_cat_dialog.add_child(panel)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	panel.add_child(main_vbox)

	var header_panel: PanelContainer = PanelContainer.new()
	var header_sb: StyleBoxFlat = StyleBoxFlat.new()
	header_sb.bg_color = pal["btn_normal"]
	header_sb.border_color = pal["panel_border"]
	header_sb.border_width_bottom = 1
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
	title_lbl.text = "Add Custom Category"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", pal["primary"])
	header_hbox.add_child(title_lbl)

	var btn_close_top: Button = Button.new()
	btn_close_top.text = "X"
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

	var form_vbox: VBoxContainer = VBoxContainer.new()
	form_vbox.add_theme_constant_override("separation", 8)
	margin.add_child(form_vbox)

	var cat_input: LineEdit = LineEdit.new()
	cat_input.placeholder_text = "Category Name (e.g. Magic, Monsters, Sci-Fi)..."
	form_vbox.add_child(cat_input)

	var btn_box: HBoxContainer = HBoxContainer.new()
	btn_box.alignment = BoxContainer.ALIGNMENT_END
	btn_box.add_theme_constant_override("separation", 8)
	form_vbox.add_child(btn_box)

	var btn_cancel: Button = Button.new()
	btn_cancel.text = "Cancel"
	btn_cancel.pressed.connect(_add_cat_dialog.queue_free)
	btn_box.add_child(btn_cancel)

	var btn_ok: Button = Button.new()
	btn_ok.text = "Create Category"
	btn_ok.icon = load("res://assets/icons/plus.svg")
	btn_ok.expand_icon = true
	btn_ok.pressed.connect(func():
		var new_cat: String = cat_input.text.strip_edges()
		if not new_cat.is_empty() and not _categories.has(new_cat):
			_categories.append(new_cat)
			_save_categories()
			_setup_category_filters()
		_add_cat_dialog.queue_free()
	)
	btn_box.add_child(btn_ok)

	ThemeManager.apply_theme(_add_cat_dialog, ThemeManager.current_theme)
	add_child(_add_cat_dialog)
	_add_cat_dialog.popup_centered()

func _update_category_buttons() -> void:
	if category_hbox == null: return
	var pal: Dictionary = ThemeManager.get_palette()
	var is_light: bool = (ThemeManager.current_theme == ThemeManager.ThemeMode.LIGHT)

	for child in category_hbox.get_children():
		if child is Button and child.text != "Add Category":
			var is_active: bool = (child.text == _current_category)
			child.button_pressed = is_active
			if is_active:
				var act_col: Color = Color.WHITE if not is_light else Color(0.1, 0.1, 0.1)
				child.add_theme_color_override("font_color", act_col)
				child.add_theme_color_override("font_pressed_color", act_col)
			else:
				var inact_col: Color = Color(0.2, 0.25, 0.35) if is_light else pal.get("text_dim", Color(0.6, 0.6, 0.6))
				child.add_theme_color_override("font_color", inact_col)

func _on_import_pressed() -> void:
	if import_dialog:
		ThemeManager.apply_theme(import_dialog, ThemeManager.current_theme)
		import_dialog.popup_centered(Vector2i(750, 480))

func _on_files_imported(paths: PackedStringArray) -> void:
	var samples_dir: String = AppPaths.get_default_samples_dir()
	if not DirAccess.dir_exists_absolute(samples_dir):
		DirAccess.make_dir_recursive_absolute(samples_dir)

	for p in paths:
		var file_name: String = p.get_file()
		var dest_path: String = samples_dir.path_join(file_name)
		DirAccess.copy_absolute(p, dest_path)

	scan_samples()

func scan_samples() -> void:
	_samples.clear()
	var metadata: Dictionary = _load_metadata()
	
	# 1. Scan default samples directory
	var samples_path: String = AppPaths.get_default_samples_dir()
	_scan_dir_for_audio(samples_path, "Custom", metadata)

	# 2. Scan library stems
	var lib_path: String = AppPaths.get_default_library_dir()
	var dir: DirAccess = DirAccess.open(lib_path)
	if dir:
		dir.list_dir_begin()
		var entry: String = dir.get_next()
		while not entry.is_empty():
			if dir.current_is_dir() and not entry.begins_with("."):
				_scan_dir_for_audio(lib_path.path_join(entry), entry.capitalize(), metadata)
			entry = dir.get_next()
		dir.list_dir_end()

	if _current_mode == BrowserMode.LOCAL:
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

	if _current_mode == BrowserMode.FREESOUND:
		_render_freesound_items()
	elif _current_mode == BrowserMode.AI_GEN:
		_render_ai_gen_items()
	else:
		_render_local_items()

func _on_ai_generate_pressed() -> void:
	if _audiogen_engine == null: return
	var p: String = _ai_prompt_edit.text.strip_edges() if _ai_prompt_edit else ""
	if p.is_empty():
		p = "Misty forest pine wind"
		if _ai_prompt_edit: _ai_prompt_edit.text = p
	var dur: float = _ai_dur_slider.value if _ai_dur_slider else 5.0
	_audiogen_engine.generate_audio(p, dur)

func _on_ai_generation_started(prompt_str: String) -> void:
	if _ai_status_label:
		_ai_status_label.text = "Synthesizing AI sound stem: '%s'..." % prompt_str
		_ai_status_label.add_theme_color_override("font_color", ThemeManager.get_palette()["primary"])
	if _ai_progress_bar:
		_ai_progress_bar.visible = true
		_ai_progress_bar.value = 0.05
	if _ai_btn_generate:
		_ai_btn_generate.disabled = true

func _on_ai_generation_progress(pct: float) -> void:
	if _ai_progress_bar:
		_ai_progress_bar.value = pct

func _on_ai_generation_completed(s_name: String, file_path: String, meta: Dictionary) -> void:
	if _ai_status_label:
		_ai_status_label.text = "✔ Generated: '%s' (Saved to %s)" % [s_name, file_path.get_file()]
		_ai_status_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	if _ai_progress_bar:
		_ai_progress_bar.visible = false
	if _ai_btn_generate:
		_ai_btn_generate.disabled = false

	_ai_generated_history.push_front({
		"name": s_name,
		"path": file_path,
		"prompt": meta.get("prompt", ""),
		"duration": meta.get("duration", 5.0),
		"icon": _detect_icon(s_name),
		"color_hex": "#00e5ff"
	})

	scan_samples()
	if _current_mode == BrowserMode.AI_GEN:
		_filter_items()

func _on_ai_generation_failed(err_msg: String) -> void:
	if _ai_status_label:
		_ai_status_label.text = "Generation Error: " + err_msg
		_ai_status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	if _ai_progress_bar:
		_ai_progress_bar.visible = false
	if _ai_btn_generate:
		_ai_btn_generate.disabled = false

func _render_ai_gen_items() -> void:
	var pal: Dictionary = ThemeManager.get_palette()

	if _ai_generated_history.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No AI stems generated in this session yet. Enter a sound description above and click '✨ Generate AI Sound Stem'!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", pal["text_dim"])
		items_container.add_child(empty_lbl)
		return

	var hdr_lbl: Label = Label.new()
	hdr_lbl.text = "Generated AI Stems in Session (%d):" % _ai_generated_history.size()
	hdr_lbl.add_theme_font_size_override("font_size", 11)
	hdr_lbl.add_theme_color_override("font_color", pal["primary"])
	items_container.add_child(hdr_lbl)

	for item in _ai_generated_history:
		var card: PanelContainer = _create_ai_item_card(item, pal)
		items_container.add_child(card)

func _create_ai_item_card(item: Dictionary, pal: Dictionary) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = pal["btn_normal"]
	sb.border_color = pal["primary"].lerp(pal["panel_border"], 0.5)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", sb)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	card.add_child(hbox)

	var icon_rect: TextureRect = TextureRect.new()
	icon_rect.texture = ThemeManager.get_sound_icon(item["icon"])
	icon_rect.custom_minimum_size = Vector2(24, 24)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.modulate = pal["primary"]
	hbox.add_child(icon_rect)

	var text_vbox: VBoxContainer = VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(text_vbox)

	var name_lbl: Label = Label.new()
	name_lbl.text = item["name"]
	name_lbl.add_theme_font_size_override("font_size", 11)
	text_vbox.add_child(name_lbl)

	var sub_lbl: Label = Label.new()
	sub_lbl.text = "Prompt: \"%s\"  |  %.1fs  |  Local AI" % [item.get("prompt", ""), item.get("duration", 5.0)]
	sub_lbl.add_theme_font_size_override("font_size", 9)
	sub_lbl.add_theme_color_override("font_color", pal["text_dim"])
	text_vbox.add_child(sub_lbl)

	# Actions
	var p_path: String = item["path"]
	var is_this_playing: bool = (preview_player and preview_player.playing and _currently_playing_path == p_path)

	var btn_play: Button = Button.new()
	btn_play.text = "■ Stop" if is_this_playing else "▶ " + LocalizationData.tr_key("BTN_PREVIEW")
	btn_play.custom_minimum_size = Vector2(90, 26)
	btn_play.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_play.add_theme_font_size_override("font_size", 10)
	btn_play.pressed.connect(func():
		_toggle_audition(p_path)
	)
	hbox.add_child(btn_play)

	var btn_add_track: Button = Button.new()
	btn_add_track.text = LocalizationData.tr_key("BTN_ADD_AS_3D_TRACK")
	btn_add_track.custom_minimum_size = Vector2(140, 26)
	btn_add_track.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_add_track.add_theme_font_size_override("font_size", 10)
	btn_add_track.pressed.connect(func():
		sample_added_to_project.emit(item["name"], p_path)
	)
	hbox.add_child(btn_add_track)

	# Delete Button (for any user/local/AI samples, not builtin res://)
	if not p_path.begins_with("res://"):
		var btn_del: Button = Button.new()
		btn_del.icon = load("res://assets/icons/trash.svg")
		btn_del.custom_minimum_size = Vector2(26, 26)
		btn_del.expand_icon = true
		btn_del.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_del.tooltip_text = LocalizationData.tr_key("TOOLTIP_DELETE")
		btn_del.modulate = Color(1.2, 0.4, 0.4)
		btn_del.pressed.connect(func():
			if preview_player and preview_player.playing and _currently_playing_path == p_path:
				preview_player.stop()
			var global_p: String = ProjectSettings.globalize_path(p_path)
			DirAccess.remove_absolute(global_p)
			
			# Remove from metadata if exists
			var meta: Dictionary = _load_metadata()
			if meta.has(p_path):
				meta.erase(p_path)
				_save_metadata(meta)
			
			# Also clean up thumbnail if it exists
			var thumb: String = p_path.get_basename() + ".png"
			if FileAccess.file_exists(thumb):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(thumb))
			
			scan_samples()
		)
		hbox.add_child(btn_del)

	return card

func _render_local_items() -> void:
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

func _render_freesound_items() -> void:
	var pal: Dictionary = ThemeManager.get_palette()

	var api_key: String = _freesound_client.get_api_key() if _freesound_client else ""
	if api_key.is_empty() or _freesound_search_status == "API_KEY_REQUIRED":
		var banner: PanelContainer = _create_freesound_api_key_banner(pal)
		items_container.add_child(banner)
		return

	if _is_freesound_searching:
		var loading_lbl: Label = Label.new()
		loading_lbl.text = "⏳ " + _freesound_search_status
		loading_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		loading_lbl.add_theme_font_size_override("font_size", 12)
		loading_lbl.add_theme_color_override("font_color", pal["primary"])
		items_container.add_child(loading_lbl)
		return

	if not _freesound_search_status.is_empty() and _freesound_results.is_empty():
		var err_lbl: Label = Label.new()
		err_lbl.text = _freesound_search_status
		err_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		err_lbl.add_theme_font_size_override("font_size", 11)
		err_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		items_container.add_child(err_lbl)
		return

	if _freesound_results.is_empty():
		var intro_lbl: Label = Label.new()
		intro_lbl.text = "Type search terms above or click quick tags to explore Freesound.org CC0 and CC-BY audio library!"
		intro_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		intro_lbl.add_theme_font_size_override("font_size", 11)
		intro_lbl.add_theme_color_override("font_color", pal["text_dim"])
		items_container.add_child(intro_lbl)
		return

	for sound in _freesound_results:
		var row: PanelContainer = _create_freesound_row(sound)
		items_container.add_child(row)

func _create_freesound_api_key_banner(pal: Dictionary) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = pal["btn_normal"]
	sb.border_color = pal["primary"].lerp(Color(1.0, 0.6, 0.1), 0.6)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	card.add_theme_stylebox_override("panel", sb)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	card.add_child(vbox)

	var title_lbl: Label = Label.new()
	title_lbl.text = "Freesound.org API-Key erforderlich (Kostenlos)"
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", pal["primary"])
	vbox.add_child(title_lbl)

	var desc_lbl: Label = Label.new()
	desc_lbl.text = "Um über 500.000 Sounds direkt aus der weltweiten Freesound-Datenbank zu durchsuchen und in 3D-Soundscapes einzubinden, benötigst du einen kostenlosen API-Key. Erstelle deinen Key in 30 Sekunden auf freesound.org und füge ihn hier ein:"
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 10)
	desc_lbl.add_theme_color_override("font_color", pal["text_dim"])
	vbox.add_child(desc_lbl)

	var hbox_input: HBoxContainer = HBoxContainer.new()
	hbox_input.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox_input)

	var key_edit: LineEdit = LineEdit.new()
	key_edit.placeholder_text = "Freesound API Client Secret / Token hier einfügen..."
	key_edit.text = _freesound_client.get_api_key() if _freesound_client else ""
	key_edit.secret = true
	key_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_edit.custom_minimum_size = Vector2(0, 32)
	key_edit.add_theme_font_size_override("font_size", 11)
	hbox_input.add_child(key_edit)

	var btn_save: Button = Button.new()
	btn_save.text = "Speichern & Suchen"
	btn_save.custom_minimum_size = Vector2(170, 32)
	btn_save.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_save.pressed.connect(func():
		var k: String = key_edit.text.strip_edges()
		if not k.is_empty():
			_freesound_client.set_api_key(k)
			_freesound_search_status = ""
			_execute_freesound_search()
	)
	hbox_input.add_child(btn_save)

	var btn_get_key: Button = Button.new()
	btn_get_key.text = "Kostenlosen API-Key auf freesound.org erstellen ↗"
	btn_get_key.custom_minimum_size = Vector2(0, 28)
	btn_get_key.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_get_key.add_theme_font_size_override("font_size", 10)
	btn_get_key.pressed.connect(func():
		OS.shell_open("https://freesound.org/apiv2/apply/")
	)
	vbox.add_child(btn_get_key)

	return card

func _create_freesound_row(sound: Dictionary) -> PanelContainer:
	var pal: Dictionary = ThemeManager.get_palette()
	var row: PanelContainer = PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 38)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	row.add_child(hbox)

	var sound_id: int = sound.get("id", 0)
	var sound_name: String = sound.get("name", "Untitled")
	var sound_author: String = sound.get("username", "Author")
	var dur: float = sound.get("duration", 0.0)
	var license: String = sound.get("license", "CC0")
	var preview_url: String = sound.get("preview_url", "")

	# Category icon detection
	var icon_key: String = _detect_icon(sound_name)
	var icon_tex: Texture2D = ThemeManager.get_sound_icon(icon_key)
	if icon_tex:
		var icon_rect: TextureRect = TextureRect.new()
		icon_rect.texture = icon_tex
		icon_rect.custom_minimum_size = Vector2(20, 20)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.modulate = pal["primary"]
		hbox.add_child(icon_rect)

	# Sound Name + Author
	var vbox_text: VBoxContainer = VBoxContainer.new()
	vbox_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_text.add_theme_constant_override("separation", 2)
	hbox.add_child(vbox_text)

	var lbl_name: Label = Label.new()
	lbl_name.text = sound_name
	lbl_name.add_theme_font_size_override("font_size", 11)
	vbox_text.add_child(lbl_name)

	var lbl_sub: Label = Label.new()
	lbl_sub.text = "by %s  •  %.1fs  •  %s" % [sound_author, dur, license.replace("https://creativecommons.org/licenses/", "").replace("http://creativecommons.org/publicdomain/zero/1.0/", "CC0")]
	lbl_sub.add_theme_font_size_override("font_size", 9)
	lbl_sub.add_theme_color_override("font_color", pal["text_dim"])
	vbox_text.add_child(lbl_sub)

	# Preview Play / Stop Button
	var btn_play: Button = Button.new()
	var is_playing: bool = (_currently_playing_path == preview_url and preview_player and preview_player.playing)
	btn_play.icon = load("res://assets/icons/stop.svg") if is_playing else load("res://assets/icons/play.svg")
	btn_play.expand_icon = true
	btn_play.tooltip_text = "Stop Preview" if is_playing else "Stream Audio Preview"
	btn_play.custom_minimum_size = Vector2(36, 26)
	btn_play.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_play.pressed.connect(func():
		_toggle_freesound_preview(preview_url)
	)
	hbox.add_child(btn_play)

	# Import to Library Button
	var is_downloading: bool = _downloading_ids.has(sound_id)
	var is_downloaded: bool = _downloaded_ids.has(sound_id)

	var btn_import_fs: Button = Button.new()
	btn_import_fs.text = "Imported ✓" if is_downloaded else ("Downloading..." if is_downloading else LocalizationData.tr_key("BTN_IMPORT_TO_LIB"))
	btn_import_fs.icon = load("res://assets/icons/save.svg")
	btn_import_fs.expand_icon = true
	btn_import_fs.custom_minimum_size = Vector2(120, 26)
	btn_import_fs.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_import_fs.disabled = is_downloading or is_downloaded
	btn_import_fs.add_theme_font_size_override("font_size", 10)
	btn_import_fs.pressed.connect(func():
		_downloading_ids[sound_id] = true
		_filter_items()
		_freesound_client.download_sound(sound, "Freesound")
	)
	hbox.add_child(btn_import_fs)

	# Add to 3D Radar Studio Button
	var btn_add_studio: Button = Button.new()
	btn_add_studio.text = LocalizationData.tr_key("BTN_ADD_TO_STUDIO")
	btn_add_studio.icon = load("res://assets/icons/plus.svg")
	btn_add_studio.expand_icon = true
	btn_add_studio.custom_minimum_size = Vector2(130, 26)
	btn_add_studio.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_add_studio.add_theme_font_size_override("font_size", 10)
	btn_add_studio.pressed.connect(func():
		if _downloaded_ids.has(sound_id):
			sample_added_to_project.emit(sound_name, _downloaded_ids[sound_id])
		else:
			# Auto-download first then add to project
			_downloading_ids[sound_id] = true
			_filter_items()
			var on_dl_comp = func(dl_id: int, file_path: String, _m: Dictionary):
				if dl_id == sound_id:
					sample_added_to_project.emit(sound_name, file_path)
			_freesound_client.download_completed.connect(on_dl_comp, CONNECT_ONE_SHOT)
			_freesound_client.download_sound(sound, "Freesound")
	)
	hbox.add_child(btn_add_studio)

	return row

func _toggle_freesound_preview(preview_url: String) -> void:
	if preview_player == null or preview_url.is_empty():
		return

	if _currently_playing_path == preview_url and preview_player.playing:
		preview_player.stop()
		_currently_playing_path = ""
		_filter_items()
	else:
		_freesound_client.fetch_preview_stream(preview_url, func(stream: AudioStream):
			if stream:
				_currently_playing_path = preview_url
				preview_player.stream = stream
				preview_player.play()
			_filter_items()
		)

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

	# Edit button (with vector edit icon)
	var btn_edit: Button = Button.new()
	btn_edit.text = "Edit"
	btn_edit.icon = load("res://assets/icons/edit.svg")
	btn_edit.expand_icon = true
	btn_edit.tooltip_text = "Edit sound name, icon, category, and accent color"
	btn_edit.custom_minimum_size = Vector2(65, 26)
	btn_edit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_edit.add_theme_font_size_override("font_size", 10)
	btn_edit.pressed.connect(func(): _open_sample_editor(s))
	hbox.add_child(btn_edit)

	# Audition Play / Stop button (Vector icon only)
	var btn_play: Button = Button.new()
	var is_playing: bool = (_currently_playing_path == s["path"] and preview_player and preview_player.playing)
	btn_play.icon = load("res://assets/icons/stop.svg") if is_playing else load("res://assets/icons/play.svg")
	btn_play.expand_icon = true
	btn_play.tooltip_text = "Stop Preview" if is_playing else "Play Audio Preview"
	btn_play.custom_minimum_size = Vector2(36, 26)
	btn_play.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_play.pressed.connect(func():
		_toggle_audition(s["path"])
	)
	hbox.add_child(btn_play)

	# Add to Soundscape button (with vector plus icon)
	var btn_add: Button = Button.new()
	btn_add.text = "Add to Studio"
	btn_add.icon = load("res://assets/icons/plus.svg")
	btn_add.expand_icon = true
	btn_add.custom_minimum_size = Vector2(110, 26)
	btn_add.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_add.add_theme_font_size_override("font_size", 10)
	btn_add.pressed.connect(func():
		sample_added_to_project.emit(s["name"], s["path"])
	)
	hbox.add_child(btn_add)

	return row

func _open_sample_editor(s: Dictionary) -> void:
	if _edit_dialog and is_instance_valid(_edit_dialog):
		_edit_dialog.queue_free()

	_edit_dialog = Window.new()
	_edit_dialog.title = ""
	_edit_dialog.size = Vector2i(440, 390)
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

	var header_panel: PanelContainer = PanelContainer.new()
	var header_sb: StyleBoxFlat = StyleBoxFlat.new()
	header_sb.bg_color = pal["btn_normal"]
	header_sb.border_color = pal["panel_border"]
	header_sb.border_width_bottom = 1
	header_sb.corner_radius_top_left = 12
	header_sb.corner_radius_top_right = 12
	header_sb.corner_radius_bottom_left = 0
	header_sb.corner_radius_bottom_right = 0
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
	title_lbl.text = "Edit Sound: " + s["name"]
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", pal["primary"])
	header_hbox.add_child(title_lbl)

	var btn_close_top: Button = Button.new()
	btn_close_top.text = "X"
	btn_close_top.custom_minimum_size = Vector2(24, 24)
	btn_close_top.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close_top.pressed.connect(_edit_dialog.queue_free)
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
	btn_save.text = "Save Changes"
	btn_save.icon = load("res://assets/icons/save.svg")
	btn_save.expand_icon = true
	btn_save.custom_minimum_size = Vector2(120, 30)
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
	panel.add_theme_stylebox_override("panel", outer_sb)
	header_panel.add_theme_stylebox_override("panel", header_sb)
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
