class_name ExportDialog
extends Window

# Author: Adromir
# Repository: https://github.com/adromir

var project: SoundscapeData.SoundscapeProject = null
var _exporter: FfmpegExporter = null

@onready var background_rect: ColorRect = $Background if has_node("Background") else null
@onready var header_panel: PanelContainer = $Margin/VBox/HeaderPanel if has_node("Margin/VBox/HeaderPanel") else null
@onready var content_panel: PanelContainer = $Margin/VBox/ContentPanel if has_node("Margin/VBox/ContentPanel") else null
@onready var btn_close: Button = $Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/BtnClose if has_node("Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/BtnClose") else null

@onready var duration_spin: SpinBox = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/DurationHBox/DurationSpin
@onready var layout_option: OptionButton = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/LayoutHBox/LayoutOption
@onready var sofa_edit: LineEdit = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/SofaHBox/SofaEdit
@onready var btn_sofa_browse: Button = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/SofaHBox/BtnBrowse
@onready var output_edit: LineEdit = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/OutputHBox/OutputEdit
@onready var btn_out_browse: Button = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/OutputHBox/BtnBrowse
@onready var progress_bar: ProgressBar = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/ProgressBar
@onready var status_label: Label = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/StatusLabel
@onready var btn_start: Button = $Margin/VBox/ButtonHBox/BtnStart
@onready var btn_cancel: Button = $Margin/VBox/ButtonHBox/BtnCancel

func _ready() -> void:
	title = LocalizationData.tr_key("DLG_EXPORT_TITLE")
	close_requested.connect(hide)

	_exporter = FfmpegExporter.new()
	_exporter.export_progress.connect(_on_export_progress)
	_exporter.export_completed.connect(_on_export_completed)
	_exporter.export_failed.connect(_on_export_failed)

	if layout_option:
		layout_option.clear()
		for key: int in SpeakerLayouts.LAYOUT_NAMES.keys():
			layout_option.add_item(SpeakerLayouts.LAYOUT_NAMES[key], key)

	if btn_close: btn_close.pressed.connect(hide)
	if btn_start: btn_start.pressed.connect(_on_start_pressed)
	if btn_cancel: btn_cancel.pressed.connect(hide)
	if btn_sofa_browse: btn_sofa_browse.pressed.connect(_browse_sofa)
	if btn_out_browse: btn_out_browse.pressed.connect(_browse_output)

	update_localization()
	_verify_ffmpeg_environment()
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

	if content_panel:
		var c_sb: StyleBoxFlat = StyleBoxFlat.new()
		c_sb.bg_color = pal["panel_bg"]
		c_sb.set_border_width_all(1)
		c_sb.border_color = pal["panel_border"]
		c_sb.set_corner_radius_all(8)
		content_panel.add_theme_stylebox_override("panel", c_sb)

	if btn_start:
		var start_sb: StyleBoxFlat = StyleBoxFlat.new()
		start_sb.bg_color = pal["primary"]
		start_sb.set_corner_radius_all(5)
		start_sb.content_margin_left = 12
		start_sb.content_margin_right = 12
		start_sb.content_margin_top = 4
		start_sb.content_margin_bottom = 4
		btn_start.add_theme_stylebox_override("normal", start_sb)
		btn_start.add_theme_color_override("font_color", Color.BLACK if mode == ThemeManager.ThemeMode.LIGHT else Color.WHITE)

	ThemeManager.apply_theme(self, mode)

func _verify_ffmpeg_environment() -> void:
	var status: Dictionary = FfmpegExporter.check_ffmpeg_status()
	if status["available"]:
		var sofa_note: String = " (SOFA supported)" if status["has_sofa_support"] else ""
		status_label.text = "✅ FFmpeg ready: %s%s" % [status["version_info"], sofa_note]
		status_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.5))
		if btn_start: btn_start.disabled = false
	else:
		status_label.text = "⚠️ FFmpeg not found in PATH or app directory. Place 'ffmpeg.exe' in application root."
		status_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
		if btn_start: btn_start.disabled = true

func update_localization() -> void:
	title = LocalizationData.tr_key("DLG_EXPORT_TITLE")
	if btn_start: btn_start.text = LocalizationData.tr_key("BTN_START_EXPORT")

func set_project(proj: SoundscapeData.SoundscapeProject) -> void:
	project = proj
	_verify_ffmpeg_environment()
	if project:
		if duration_spin: duration_spin.value = project.target_duration_sec
		if layout_option: layout_option.select(project.speaker_layout)
		if sofa_edit: sofa_edit.text = project.sofa_path
		if output_edit: output_edit.text = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).path_join(project.title.validate_filename() + ".wav")

func open_for_project(proj: SoundscapeData.SoundscapeProject) -> void:
	set_project(proj)
	popup_centered(Vector2i(640, 480))

func _browse_sofa() -> void:
	var fd: FileDialog = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.filters = PackedStringArray(["*.sofa ; SOFA HRTF Files"])
	fd.use_native_dialog = false
	ThemeManager.apply_theme(fd, ThemeManager.current_theme)
	add_child(fd)
	fd.file_selected.connect(func(path: String):
		if sofa_edit: sofa_edit.text = path
		if project: project.sofa_path = path
		fd.queue_free()
	)
	fd.canceled.connect(func(): fd.queue_free())
	fd.popup_centered(Vector2i(600, 400))

func _browse_output() -> void:
	var fd: FileDialog = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.filters = PackedStringArray(["*.wav ; WAV Audio", "*.flac ; FLAC Audio", "*.mp3 ; MP3 Audio"])
	fd.use_native_dialog = false
	ThemeManager.apply_theme(fd, ThemeManager.current_theme)
	add_child(fd)
	fd.file_selected.connect(func(path: String):
		if output_edit: output_edit.text = path
		fd.queue_free()
	)
	fd.canceled.connect(func(): fd.queue_free())
	fd.popup_centered(Vector2i(600, 400))

func _on_start_pressed() -> void:
	if project == null:
		return

	var out_path: String = output_edit.text.strip_edges() if output_edit else ""
	if out_path.is_empty():
		status_label.text = "Please specify an output path."
		return

	var duration: int = int(duration_spin.value) if duration_spin else 300
	var sofa_file: String = sofa_edit.text.strip_edges() if sofa_edit else ""
	var layout: SpeakerLayouts.LayoutType = (layout_option.selected if layout_option else SpeakerLayouts.LayoutType.BINAURAL_SOFA) as SpeakerLayouts.LayoutType

	btn_start.disabled = true
	progress_bar.visible = true
	progress_bar.value = 10
	status_label.text = "Rendering..."

	_exporter.start_offline_render(project, out_path, duration, sofa_file, layout)

func _on_export_progress(percent: float, message: String) -> void:
	progress_bar.value = percent
	status_label.text = message

func _on_export_completed(_exit_code: int, out_path: String) -> void:
	btn_start.disabled = false
	progress_bar.visible = false
	status_label.text = "Export successful: " + out_path

func _on_export_failed(reason: String) -> void:
	btn_start.disabled = false
	progress_bar.visible = false
	status_label.text = "Export failed: " + reason
