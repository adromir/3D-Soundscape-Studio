class_name SettingsDialog
extends Window

# Author: Adromir
# Repository: https://github.com/adromir

const AppPaths = preload("res://src/core/app_paths.gd")

signal settings_saved()

static func get_settings_file() -> String:
	return AppPaths.get_settings_file()

@onready var background_rect: ColorRect = $Background if has_node("Background") else null
@onready var header_panel: PanelContainer = $Margin/VBox/HeaderPanel if has_node("Margin/VBox/HeaderPanel") else null
@onready var title_label: Label = $Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/TitleLabel if has_node("Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/TitleLabel") else null
@onready var btn_close: Button = $Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/BtnClose if has_node("Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/BtnClose") else null

@onready var tabs: TabContainer = $Margin/VBox/Tabs

@onready var device_option: OptionButton = $Margin/VBox/Tabs/AudioTab/DeviceOption
@onready var layout_option: OptionButton = $Margin/VBox/Tabs/AudioTab/LayoutOption

@onready var lib_path_edit: LineEdit = $Margin/VBox/Tabs/DirectoriesTab/LibHBox/LibPathEdit
@onready var btn_browse_lib: Button = $Margin/VBox/Tabs/DirectoriesTab/LibHBox/BtnBrowseLib

@onready var samples_path_edit: LineEdit = $Margin/VBox/Tabs/DirectoriesTab/SamplesHBox/SamplesPathEdit
@onready var btn_browse_samples: Button = $Margin/VBox/Tabs/DirectoriesTab/SamplesHBox/BtnBrowseSamples

@onready var export_path_edit: LineEdit = $Margin/VBox/Tabs/DirectoriesTab/ExportHBox/ExportPathEdit
@onready var btn_browse_export: Button = $Margin/VBox/Tabs/DirectoriesTab/ExportHBox/BtnBrowseExport

@onready var sofa_path_edit: LineEdit = $Margin/VBox/Tabs/DirectoriesTab/SofaHBox/SofaPathEdit
@onready var btn_browse_sofa: Button = $Margin/VBox/Tabs/DirectoriesTab/SofaHBox/BtnBrowseSofa

@onready var ffmpeg_path_edit: LineEdit = $Margin/VBox/Tabs/FFmpegTab/FFmpegHBox/FFmpegPathEdit
@onready var btn_browse_ffmpeg: Button = $Margin/VBox/Tabs/FFmpegTab/FFmpegHBox/BtnBrowseFFmpeg
@onready var btn_test_ffmpeg: Button = $Margin/VBox/Tabs/FFmpegTab/FFmpegHBox/BtnTestFFmpeg
@onready var ffmpeg_status_lbl: Label = $Margin/VBox/Tabs/FFmpegTab/FFmpegStatusLabel

@onready var chk_radar_animation: CheckBox = $Margin/VBox/Tabs/DisplayTab/ChkRadarAnimation
@onready var chk_check_updates: CheckBox = $Margin/VBox/Tabs/DisplayTab/ChkCheckUpdates if has_node("Margin/VBox/Tabs/DisplayTab/ChkCheckUpdates") else null
@onready var language_label: Label = $Margin/VBox/Tabs/DisplayTab/LanguageLabel if has_node("Margin/VBox/Tabs/DisplayTab/LanguageLabel") else null
@onready var language_option: OptionButton = $Margin/VBox/Tabs/DisplayTab/LanguageOption if has_node("Margin/VBox/Tabs/DisplayTab/LanguageOption") else null
@onready var theme_label: Label = $Margin/VBox/Tabs/DisplayTab/ThemeLabel if has_node("Margin/VBox/Tabs/DisplayTab/ThemeLabel") else null
@onready var theme_option: OptionButton = $Margin/VBox/Tabs/DisplayTab/ThemeOption if has_node("Margin/VBox/Tabs/DisplayTab/ThemeOption") else null
@onready var radar_anim_label: Label = $Margin/VBox/Tabs/DisplayTab/RadarAnimationLabel if has_node("Margin/VBox/Tabs/DisplayTab/RadarAnimationLabel") else null

@onready var btn_save: Button = $Margin/VBox/BottomHBox/BtnSaveSettings
@onready var btn_cancel: Button = $Margin/VBox/BottomHBox/BtnCancelSettings
@onready var path_file_dialog: FileDialog = $PathFileDialog

var _active_browse_target: LineEdit = null

func _ready() -> void:
	title = "⚙️ Studio Preferences & Settings"
	close_requested.connect(hide)
	
	if btn_close:
		btn_close.pressed.connect(hide)
	if btn_cancel:
		btn_cancel.pressed.connect(hide)
	if btn_save:
		btn_save.pressed.connect(_on_save_pressed)
	if btn_test_ffmpeg:
		btn_test_ffmpeg.pressed.connect(_test_ffmpeg_path)

	_setup_browse_buttons()
	_populate_devices()
	_populate_layouts()
	_populate_languages()
	_populate_themes()
	load_settings()
	_setup_realtime_sync()
	update_localization()
	apply_theme(ThemeManager.current_theme)

func apply_theme(mode: ThemeManager.ThemeMode) -> void:
	var pal: Dictionary = ThemeManager.get_palette_for_mode(mode)
	var orbs: Dictionary = ThemeManager.get_orb_colors(mode)

	if background_rect and background_rect.material is ShaderMaterial:
		var mat: ShaderMaterial = background_rect.material as ShaderMaterial
		mat.set_shader_parameter("bg_color", orbs["bg"])
		mat.set_shader_parameter("orb1_color", orbs["orb1"])
		mat.set_shader_parameter("orb2_color", orbs["orb2"])
		mat.set_shader_parameter("orb3_color", orbs["orb3"])
		if mode == ThemeManager.ThemeMode.ZEN:
			mat.set_shader_parameter("use_texture", true)
			if ResourceLoader.exists("res://assets/textures/zen/bg_zen_atmosphere.png"):
				mat.set_shader_parameter("bg_texture", load("res://assets/textures/zen/bg_zen_atmosphere.png"))
		else:
			mat.set_shader_parameter("use_texture", false)

	if header_panel:
		var h_sb: StyleBoxFlat = StyleBoxFlat.new()
		h_sb.bg_color = pal["panel_bg"]
		h_sb.set_border_width_all(1)
		h_sb.border_color = pal["panel_border_glow"]
		h_sb.set_corner_radius_all(8)
		header_panel.add_theme_stylebox_override("panel", h_sb)

	if btn_save:
		var save_sb: StyleBoxFlat = StyleBoxFlat.new()
		save_sb.bg_color = pal["primary"]
		save_sb.set_corner_radius_all(5)
		save_sb.content_margin_left = 12
		save_sb.content_margin_right = 12
		save_sb.content_margin_top = 4
		save_sb.content_margin_bottom = 4
		btn_save.add_theme_stylebox_override("normal", save_sb)
		btn_save.add_theme_color_override("font_color", Color.BLACK if mode == ThemeManager.ThemeMode.LIGHT else Color.WHITE)

	ThemeManager.apply_theme(self, mode)

func _setup_browse_buttons() -> void:
	if path_file_dialog:
		path_file_dialog.dir_selected.connect(_on_path_dialog_selected)
		path_file_dialog.file_selected.connect(_on_path_dialog_selected)

	if btn_browse_lib:
		btn_browse_lib.pressed.connect(func(): _open_picker(lib_path_edit, FileDialog.FILE_MODE_OPEN_DIR, "Select Soundscape Library Directory"))
	if btn_browse_samples:
		btn_browse_samples.pressed.connect(func(): _open_picker(samples_path_edit, FileDialog.FILE_MODE_OPEN_DIR, "Select Samples Pool Directory"))
	if btn_browse_export:
		btn_browse_export.pressed.connect(func(): _open_picker(export_path_edit, FileDialog.FILE_MODE_OPEN_DIR, "Select Audio Export Directory"))
	if btn_browse_sofa:
		btn_browse_sofa.pressed.connect(func(): _open_picker(sofa_path_edit, FileDialog.FILE_MODE_OPEN_FILE, "Select HRTF SOFA File", ["*.sofa ; SOFA HRTF Files"]))
	if btn_browse_ffmpeg:
		btn_browse_ffmpeg.pressed.connect(func(): _open_picker(ffmpeg_path_edit, FileDialog.FILE_MODE_OPEN_FILE, "Select FFmpeg Executable", ["*.exe ; Executables", "*.* ; All Files"]))

func _open_picker(target_edit: LineEdit, mode: FileDialog.FileMode, dialog_title: String, filters: Array[String] = []) -> void:
	if path_file_dialog == null: return
	_active_browse_target = target_edit
	path_file_dialog.file_mode = mode
	path_file_dialog.title = dialog_title
	path_file_dialog.filters = filters
	ThemeManager.apply_theme(path_file_dialog, ThemeManager.current_theme)
	path_file_dialog.popup_centered(Vector2i(700, 450))

func _on_path_dialog_selected(selected_path: String) -> void:
	if _active_browse_target:
		_active_browse_target.text = selected_path

func _populate_devices() -> void:
	if device_option == null:
		return
	device_option.clear()
	var devices: PackedStringArray = AudioServer.get_output_device_list()
	var current_dev: String = AudioServer.get_output_device()
	var current_idx: int = 0
	for i in range(devices.size()):
		var dev: String = devices[i]
		device_option.add_item(dev, i)
		if dev == current_dev:
			current_idx = i
	device_option.select(current_idx)

func _populate_layouts() -> void:
	if layout_option == null:
		return
	layout_option.clear()
	for key: int in SpeakerLayouts.LAYOUT_NAMES.keys():
		layout_option.add_item(SpeakerLayouts.LAYOUT_NAMES[key], key)

func _populate_languages() -> void:
	if language_option == null:
		return
	language_option.clear()
	for key: int in LocalizationData.LANGUAGE_NAMES.keys():
		language_option.add_item(LocalizationData.LANGUAGE_NAMES[key], key)

func _populate_themes() -> void:
	if theme_option == null:
		return
	theme_option.clear()
	for key: int in ThemeManager.THEME_NAMES.keys():
		theme_option.add_item(ThemeManager.THEME_NAMES[key], key)

func load_settings() -> Dictionary:
	var data: Dictionary = {
		"output_device": AudioServer.get_output_device(),
		"speaker_layout": 0,
		"library_path": AppPaths.get_default_library_dir(),
		"samples_path": AppPaths.get_default_samples_dir(),
		"export_path": AppPaths.get_default_exports_dir(),
		"sofa_path": AppPaths.get_default_sofa_dir(),
		"ffmpeg_path": FfmpegExporter.get_ffmpeg_binary_path(),
		"language": "EN",
		"theme": "ZEN",
		"dock_tracks": true,
		"dock_radar": true,
		"dock_inspector": true,
		"radar_animation": true
	}
	if FileAccess.file_exists(get_settings_file()):
		var file: FileAccess = FileAccess.open(get_settings_file(), FileAccess.READ)
		if file:
			var json_str: String = file.get_as_text()
			file.close()
			var json: JSON = JSON.new()
			if json.parse(json_str) == OK and json.data is Dictionary:
				for k in json.data.keys():
					data[k] = json.data[k]

	if lib_path_edit: lib_path_edit.text = data.get("library_path", "")
	if samples_path_edit: samples_path_edit.text = data.get("samples_path", "")
	if export_path_edit: export_path_edit.text = data.get("export_path", "")
	if sofa_path_edit: sofa_path_edit.text = data.get("sofa_path", "")
	if ffmpeg_path_edit: ffmpeg_path_edit.text = data.get("ffmpeg_path", "")
	if layout_option: layout_option.select(int(data.get("speaker_layout", 0)))
	if chk_radar_animation: chk_radar_animation.button_pressed = bool(data.get("radar_animation", true))
	if chk_check_updates: chk_check_updates.button_pressed = bool(data.get("check_updates_on_startup", true))

	if language_option:
		var lang_code = data.get("language", "EN")
		var lang_enum: LocalizationData.Language = LocalizationData.Language.EN
		if str(lang_code) in ["DE", "1"]: lang_enum = LocalizationData.Language.DE
		elif str(lang_code) in ["FR", "2"]: lang_enum = LocalizationData.Language.FR
		elif str(lang_code) in ["ES", "3"]: lang_enum = LocalizationData.Language.ES
		elif str(lang_code) in ["IT", "4"]: lang_enum = LocalizationData.Language.IT
		language_option.select(lang_enum as int)

	if theme_option:
		var th_val = data.get("theme", "ZEN")
		var th_mode: ThemeManager.ThemeMode = ThemeManager.ThemeMode.ZEN
		if str(th_val) in ["0", "DARK"]: th_mode = ThemeManager.ThemeMode.DARK
		elif str(th_val) in ["1", "LIGHT"]: th_mode = ThemeManager.ThemeMode.LIGHT
		elif str(th_val) in ["2", "CYBERPUNK"]: th_mode = ThemeManager.ThemeMode.CYBERPUNK
		elif str(th_val) in ["3", "ZEN"]: th_mode = ThemeManager.ThemeMode.ZEN
		theme_option.select(th_mode as int)

	return data

func _setup_realtime_sync() -> void:
	if device_option:
		device_option.item_selected.connect(func(idx: int):
			var dev: String = device_option.get_item_text(idx)
			AudioServer.set_output_device(dev)
			_save_current_settings(false)
		)
	if layout_option:
		layout_option.item_selected.connect(func(_idx: int):
			_save_current_settings(false)
		)
	if chk_radar_animation:
		chk_radar_animation.toggled.connect(func(_val: bool):
			_save_current_settings(false)
		)
	if chk_check_updates:
		chk_check_updates.toggled.connect(func(_val: bool):
			_save_current_settings(false)
		)
	if language_option:
		language_option.item_selected.connect(func(idx: int):
			LocalizationData.set_language(idx as LocalizationData.Language)
			update_localization()
			_save_current_settings(false)
		)
	if theme_option:
		theme_option.item_selected.connect(func(idx: int):
			apply_theme(idx as ThemeManager.ThemeMode)
			_save_current_settings(false)
		)
	for edit in [lib_path_edit, samples_path_edit, export_path_edit, sofa_path_edit, ffmpeg_path_edit]:
		if edit:
			edit.text_changed.connect(func(_t: String):
				_save_current_settings(false)
			)

func _on_save_pressed() -> void:
	_save_current_settings(true)

func _save_current_settings(should_hide: bool = false) -> void:
	var existing_data: Dictionary = {}
	if FileAccess.file_exists(get_settings_file()):
		var fr: FileAccess = FileAccess.open(get_settings_file(), FileAccess.READ)
		if fr:
			var json: JSON = JSON.new()
			if json.parse(fr.get_as_text()) == OK and json.data is Dictionary:
				existing_data = json.data
			fr.close()

	existing_data["output_device"] = device_option.get_item_text(device_option.selected) if device_option else ""
	existing_data["speaker_layout"] = layout_option.selected if layout_option else 0
	existing_data["library_path"] = lib_path_edit.text.strip_edges() if lib_path_edit else ""
	existing_data["samples_path"] = samples_path_edit.text.strip_edges() if samples_path_edit else ""
	existing_data["export_path"] = export_path_edit.text.strip_edges() if export_path_edit else ""
	existing_data["sofa_path"] = sofa_path_edit.text.strip_edges() if sofa_path_edit else ""
	existing_data["ffmpeg_path"] = ffmpeg_path_edit.text.strip_edges() if ffmpeg_path_edit else ""
	existing_data["radar_animation"] = chk_radar_animation.button_pressed if chk_radar_animation else true
	existing_data["check_updates_on_startup"] = chk_check_updates.button_pressed if chk_check_updates else true

	if language_option:
		existing_data["language"] = LocalizationData.LANGUAGE_CODES.get(language_option.selected as LocalizationData.Language, "EN")
	if theme_option:
		var th_enum: ThemeManager.ThemeMode = theme_option.selected as ThemeManager.ThemeMode
		existing_data["theme"] = "DARK" if th_enum == ThemeManager.ThemeMode.DARK else ("LIGHT" if th_enum == ThemeManager.ThemeMode.LIGHT else ("CYBERPUNK" if th_enum == ThemeManager.ThemeMode.CYBERPUNK else "ZEN"))

	if not existing_data["output_device"].is_empty():
		AudioServer.set_output_device(existing_data["output_device"])

	var file: FileAccess = FileAccess.open(get_settings_file(), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(existing_data, "\t"))
		file.close()

	settings_saved.emit()
	if should_hide:
		hide()

func _test_ffmpeg_path() -> void:
	var path: String = ffmpeg_path_edit.text.strip_edges() if ffmpeg_path_edit else ""
	if path.is_empty():
		path = "ffmpeg"
	
	var output: Array = []
	var exit_code: int = OS.execute(path, ["-version"], output, true)
	if exit_code == 0 and not output.is_empty():
		var first_line: String = output[0].split("\n")[0]
		if ffmpeg_status_lbl:
			ffmpeg_status_lbl.text = "✅ Found: " + first_line
			ffmpeg_status_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	else:
		if ffmpeg_status_lbl:
			ffmpeg_status_lbl.text = "❌ FFmpeg not found at this path"
			ffmpeg_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

func update_localization() -> void:
	title = LocalizationData.tr_key("SETTINGS_TITLE")
	if title_label: title_label.text = LocalizationData.tr_key("SETTINGS_TITLE")
	if tabs:
		tabs.set_tab_title(0, LocalizationData.tr_key("SETTINGS_TAB_AUDIO"))
		tabs.set_tab_title(1, LocalizationData.tr_key("SETTINGS_TAB_DIRECTORIES"))
		tabs.set_tab_title(2, LocalizationData.tr_key("SETTINGS_TAB_FFMPEG"))
		tabs.set_tab_title(3, LocalizationData.tr_key("SETTINGS_TAB_DISPLAY"))
	
	var dev_lbl = get_node_or_null("Margin/VBox/Tabs/AudioTab/DeviceLabel")
	if dev_lbl: dev_lbl.text = LocalizationData.tr_key("SETTINGS_AUDIO_DEVICE")
	var layout_lbl = get_node_or_null("Margin/VBox/Tabs/AudioTab/LayoutLabel")
	if layout_lbl: layout_lbl.text = LocalizationData.tr_key("SETTINGS_SPEAKER_LAYOUT")
	
	var lib_lbl = get_node_or_null("Margin/VBox/Tabs/DirectoriesTab/LibPathLabel")
	if lib_lbl: lib_lbl.text = LocalizationData.tr_key("SETTINGS_LIB_DIR_LABEL")
	var samples_lbl = get_node_or_null("Margin/VBox/Tabs/DirectoriesTab/SamplesPathLabel")
	if samples_lbl: samples_lbl.text = LocalizationData.tr_key("SETTINGS_SAMPLES_DIR_LABEL")
	var export_lbl = get_node_or_null("Margin/VBox/Tabs/DirectoriesTab/ExportPathLabel")
	if export_lbl: export_lbl.text = LocalizationData.tr_key("SETTINGS_EXPORTS_DIR_LABEL")
	var sofa_lbl = get_node_or_null("Margin/VBox/Tabs/DirectoriesTab/SofaPathLabel")
	if sofa_lbl: sofa_lbl.text = LocalizationData.tr_key("SETTINGS_SOFA_LABEL")

	for b in [btn_browse_lib, btn_browse_samples, btn_browse_export, btn_browse_sofa, btn_browse_ffmpeg]:
		if b: b.text = LocalizationData.tr_key("BTN_BROWSE")

	var ffmpeg_lbl = get_node_or_null("Margin/VBox/Tabs/FFmpegTab/FFmpegPathLabel")
	if ffmpeg_lbl: ffmpeg_lbl.text = LocalizationData.tr_key("SETTINGS_FFMPEG_PATH_LABEL")
	if btn_test_ffmpeg: btn_test_ffmpeg.text = LocalizationData.tr_key("SETTINGS_FFMPEG_TEST_BTN")

	if language_label: language_label.text = LocalizationData.tr_key("SETTINGS_LANGUAGE_LABEL")
	if theme_label: theme_label.text = LocalizationData.tr_key("SETTINGS_THEME_LABEL")
	if radar_anim_label: radar_anim_label.text = LocalizationData.tr_key("SETTINGS_RADAR_ANIM_LABEL")
	if chk_radar_animation: chk_radar_animation.text = LocalizationData.tr_key("SETTINGS_RADAR_BEAM_CHK")
	var upd_lbl = get_node_or_null("Margin/VBox/Tabs/DisplayTab/UpdatesLabel")
	if upd_lbl: upd_lbl.text = LocalizationData.tr_key("DLG_UPDATE_TITLE")
	if chk_check_updates: chk_check_updates.text = LocalizationData.tr_key("SETTINGS_CHECK_UPDATES_STARTUP")
	if btn_save: btn_save.text = LocalizationData.tr_key("SETTINGS_SAVE")
	if btn_cancel: btn_cancel.text = LocalizationData.tr_key("SETTINGS_CANCEL")
