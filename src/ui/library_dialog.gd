class_name LibraryDialog
extends Window

# Author: Adromir
# Repository: https://github.com/adromir

signal soundscape_loaded(project: SoundscapeData.SoundscapeProject)

var _client: AmbientMixerClient = null
var _search_query: String = ""

@onready var background: ColorRect = $Background
@onready var search_input: LineEdit = $Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/SearchInput
@onready var lib_title_label: Label = $Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/LibTitleLabel
@onready var url_input: LineEdit = $Margin/VBox/DownloadPanel/DownloadMargin/DownloadBar/UrlInput
@onready var btn_download: Button = $Margin/VBox/DownloadPanel/DownloadMargin/DownloadBar/BtnDownload
@onready var progress_bar: ProgressBar = $Margin/VBox/ProgressBar
@onready var status_label: Label = $Margin/VBox/StatusLabel
@onready var items_container: GridContainer = $Margin/VBox/LibraryScroll/ItemsContainer

func _ready() -> void:
	title = LocalizationData.tr_key("DLG_DOWNLOAD_TITLE")
	close_requested.connect(hide)

	_client = AmbientMixerClient.new()
	add_child(_client)
	_client.progress_changed.connect(_on_client_progress)
	_client.download_completed.connect(_on_client_completed)
	_client.download_failed.connect(_on_client_failed)

	if btn_download:
		btn_download.pressed.connect(_on_download_pressed)

	if search_input:
		search_input.text_changed.connect(_on_search_changed)

	apply_theme(ThemeManager.current_theme)
	refresh_library()
	update_localization()

func apply_theme(mode: ThemeManager.ThemeMode) -> void:
	var orbs: Dictionary = ThemeManager.get_orb_colors(mode)
	if background and background.material is ShaderMaterial:
		var mat: ShaderMaterial = background.material as ShaderMaterial
		mat.set_shader_parameter("bg_color", orbs.get("bg", Color(0.035, 0.048, 0.082, 1.0)))
		mat.set_shader_parameter("orb1_color", orbs.get("orb1", Color(0.0, 0.55, 0.95, 0.35)))
		mat.set_shader_parameter("orb2_color", orbs.get("orb2", Color(0.45, 0.15, 0.85, 0.28)))
		mat.set_shader_parameter("orb3_color", orbs.get("orb3", Color(0.0, 0.85, 0.8, 0.22)))
		if mode == ThemeManager.ThemeMode.ZEN:
			mat.set_shader_parameter("use_texture", true)
			if ResourceLoader.exists("res://assets/textures/zen/bg_zen_atmosphere.png"):
				mat.set_shader_parameter("bg_texture", load("res://assets/textures/zen/bg_zen_atmosphere.png"))
		else:
			mat.set_shader_parameter("use_texture", false)

	ThemeManager.apply_theme(self, mode)
	refresh_library()

func update_localization() -> void:
	title = LocalizationData.tr_key("DLG_DOWNLOAD_TITLE")
	if lib_title_label:
		lib_title_label.text = LocalizationData.tr_key("DLG_DOWNLOAD_TITLE")
	if btn_download:
		btn_download.text = "⬇ " + LocalizationData.tr_key("BTN_DOWNLOAD")

func _on_search_changed(query: String) -> void:
	_search_query = query.strip_edges().to_lower()
	refresh_library()

func _on_download_pressed() -> void:
	if url_input == null or url_input.text.strip_edges().is_empty():
		return
	btn_download.disabled = true
	progress_bar.visible = true
	status_label.visible = true
	progress_bar.value = 0
	status_label.text = "Starting download..."
	_client.start_import_from_url(url_input.text.strip_edges())

func _on_client_progress(curr: int, total: int, status_text: String) -> void:
	progress_bar.max_value = total
	progress_bar.value = curr
	status_label.text = status_text

func _on_client_completed(_project_path: String, project: SoundscapeData.SoundscapeProject) -> void:
	btn_download.disabled = false
	progress_bar.visible = false
	status_label.visible = true
	status_label.text = "Downloaded successfully: " + project.title
	refresh_library()
	soundscape_loaded.emit(project)
	hide()

func _on_client_failed(err: String) -> void:
	btn_download.disabled = false
	progress_bar.visible = false
	status_label.visible = true
	status_label.text = "Error: " + err

func refresh_library() -> void:
	if items_container == null:
		return

	for child in items_container.get_children():
		child.queue_free()

	var pal: Dictionary = ThemeManager.get_palette()
	var soundscapes: Array[Dictionary] = LibraryManager.get_all_soundscapes()

	for info in soundscapes:
		var title_str: String = info.get("title", "")
		var author_str: String = info.get("author", "")

		# Search Filter
		if not _search_query.is_empty():
			if not title_str.to_lower().contains(_search_query) and not author_str.to_lower().contains(_search_query):
				continue

		# Card Container with Glass styling
		var card: PanelContainer = PanelContainer.new()
		card.custom_minimum_size = Vector2(240, 245)

		var card_sb: StyleBoxFlat = StyleBoxFlat.new()
		card_sb.bg_color = pal.get("panel_bg", Color(0.055, 0.082, 0.155, 0.60))
		card_sb.set_border_width_all(1)
		card_sb.border_color = pal.get("panel_border", Color(0.25, 0.65, 0.95, 0.22))
		card_sb.set_corner_radius_all(8)
		card_sb.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
		card_sb.shadow_size = 6
		card.add_theme_stylebox_override("panel", card_sb)

		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_bottom", 8)
		card.add_child(margin)

		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		margin.add_child(vbox)

		# Cover Image
		var cover_rect: TextureRect = TextureRect.new()
		cover_rect.custom_minimum_size = Vector2(0, 115)
		cover_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cover_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cover_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

		var cover_loaded: bool = false
		if not info.get("cover_path", "").is_empty():
			var global_cov: String = ProjectSettings.globalize_path(info["cover_path"])
			if FileAccess.file_exists(global_cov):
				var img: Image = Image.new()
				if img.load(global_cov) == OK:
					var tex: ImageTexture = ImageTexture.create_from_image(img)
					cover_rect.texture = tex
					cover_loaded = true

		if not cover_loaded:
			var placeholder_bg: ColorRect = ColorRect.new()
			placeholder_bg.color = pal.get("btn_normal", Color(0.08, 0.12, 0.22, 0.65))
			placeholder_bg.custom_minimum_size = Vector2(0, 115)
			placeholder_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var icon_res: Texture2D = ThemeManager.get_sound_icon("music")
			if icon_res:
				var placeholder_icon: TextureRect = TextureRect.new()
				placeholder_icon.texture = icon_res
				placeholder_icon.custom_minimum_size = Vector2(36, 36)
				placeholder_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				placeholder_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				placeholder_icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
				placeholder_icon.modulate = pal.get("primary", Color.CYAN) * Color(1, 1, 1, 0.6)
				placeholder_bg.add_child(placeholder_icon)
			vbox.add_child(placeholder_bg)
		else:
			vbox.add_child(cover_rect)

		# Title
		var lbl_title: Label = Label.new()
		lbl_title.text = title_str
		lbl_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_title.max_lines_visible = 2
		lbl_title.add_theme_font_size_override("font_size", 12)
		lbl_title.add_theme_color_override("font_color", pal.get("text_main", Color.WHITE))
		vbox.add_child(lbl_title)

		# Author / Details
		var lbl_author: Label = Label.new()
		lbl_author.text = "By " + author_str
		lbl_author.add_theme_color_override("font_color", pal.get("primary", Color(0.0, 0.949, 0.996, 1.0)) * Color(1, 1, 1, 0.85))
		lbl_author.add_theme_font_size_override("font_size", 10)
		vbox.add_child(lbl_author)

		var spacer: Control = Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.add_child(spacer)

		# Action Buttons (Load / Delete)
		var btn_hbox: HBoxContainer = HBoxContainer.new()
		btn_hbox.add_theme_constant_override("separation", 6)
		vbox.add_child(btn_hbox)

		var btn_load: Button = Button.new()
		btn_load.text = "▶ Load Project"
		btn_load.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_load.custom_minimum_size = Vector2(0, 28)
		btn_load.add_theme_font_size_override("font_size", 11)
		btn_load.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		# Load button accent theme styling
		var load_sb: StyleBoxFlat = StyleBoxFlat.new()
		load_sb.bg_color = pal.get("btn_normal", Color(0.08, 0.12, 0.22, 0.65))
		load_sb.set_border_width_all(1)
		load_sb.border_color = pal.get("panel_border", Color.CYAN)
		load_sb.set_corner_radius_all(5)
		btn_load.add_theme_stylebox_override("normal", load_sb)

		var load_sb_h: StyleBoxFlat = StyleBoxFlat.new()
		load_sb_h.bg_color = pal.get("btn_hover", Color(0.0, 0.85, 0.98, 0.20))
		load_sb_h.set_border_width_all(1)
		load_sb_h.border_color = pal.get("panel_border_glow", Color.CYAN)
		load_sb_h.set_corner_radius_all(5)
		btn_load.add_theme_stylebox_override("hover", load_sb_h)

		var proj_file: String = info["project_path"]
		btn_load.pressed.connect(func():
			var loaded_proj: SoundscapeData.SoundscapeProject = SoundscapeData.SoundscapeProject.load_from_file(proj_file)
			if loaded_proj:
				soundscape_loaded.emit(loaded_proj)
				hide()
		)
		btn_hbox.add_child(btn_load)

		var btn_del: Button = Button.new()
		btn_del.text = "✕"
		btn_del.custom_minimum_size = Vector2(28, 28)
		btn_del.add_theme_font_size_override("font_size", 11)
		btn_del.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var folder_to_del: String = info["folder_name"]
		btn_del.pressed.connect(func():
			LibraryManager.delete_soundscape(folder_to_del)
			refresh_library()
		)
		btn_hbox.add_child(btn_del)

		items_container.add_child(card)
