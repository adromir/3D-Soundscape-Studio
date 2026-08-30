class_name SoundscapeBrowser
extends PanelContainer

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

signal soundscape_loaded(project: SoundscapeData.SoundscapeProject)

var _client: AmbientMixerClient = null
var _search_query: String = ""
var _selected_slug_for_cover: String = ""

@onready var search_input: LineEdit = $VBox/HeaderPanel/HeaderMargin/HeaderHBox/SearchInput if has_node("VBox/HeaderPanel/HeaderMargin/HeaderHBox/SearchInput") else null
@onready var lib_title_label: Label = $VBox/HeaderPanel/HeaderMargin/HeaderHBox/LibTitleLabel if has_node("VBox/HeaderPanel/HeaderMargin/HeaderHBox/LibTitleLabel") else null
@onready var url_input: LineEdit = $VBox/DownloadPanel/DownloadMargin/DownloadBar/UrlInput if has_node("VBox/DownloadPanel/DownloadMargin/DownloadBar/UrlInput") else null
@onready var btn_download: Button = $VBox/DownloadPanel/DownloadMargin/DownloadBar/BtnDownload if has_node("VBox/DownloadPanel/DownloadMargin/DownloadBar/BtnDownload") else null
@onready var progress_bar: ProgressBar = $VBox/ProgressBar if has_node("VBox/ProgressBar") else null
@onready var status_label: Label = $VBox/StatusLabel if has_node("VBox/StatusLabel") else null
@onready var items_container: GridContainer = $VBox/LibraryScroll/ItemsContainer if has_node("VBox/LibraryScroll/ItemsContainer") else null
@onready var cover_file_dialog: FileDialog = $CoverFileDialog if has_node("CoverFileDialog") else null

func _ready() -> void:
	_client = AmbientMixerClient.new()
	add_child(_client)
	_client.progress_changed.connect(_on_client_progress)
	_client.download_completed.connect(_on_client_completed)
	_client.download_failed.connect(_on_client_failed)

	if btn_download:
		btn_download.icon = load("res://assets/icons/plus.svg")
		btn_download.expand_icon = true
		btn_download.pressed.connect(_on_download_pressed)

	if search_input:
		search_input.text_changed.connect(_on_search_changed)

	if cover_file_dialog:
		cover_file_dialog.file_selected.connect(_on_cover_file_selected)

	apply_theme(ThemeManager.current_theme)
	refresh_library()
	update_localization()

func apply_theme(mode: ThemeManager.ThemeMode) -> void:
	ThemeManager.apply_theme(self, mode)
	refresh_library()

func update_localization() -> void:
	if lib_title_label:
		lib_title_label.text = LocalizationData.tr_key("TAB_SOUNDSCAPES")
	if btn_download:
		btn_download.text = LocalizationData.tr_key("BTN_DOWNLOAD")

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

	var list: Array[Dictionary] = LibraryManager.get_all_soundscapes()
	var pal: Dictionary = ThemeManager.get_palette()

	var displayed_count: int = 0
	for item in list:
		var title_str: String = item.get("title", "")
		var author_str: String = item.get("author", "")
		var tags_str: String = item.get("tags", "")

		# Search Filter
		if not _search_query.is_empty():
			var combined: String = (title_str + " " + author_str + " " + tags_str).to_lower()
			if not combined.contains(_search_query):
				continue

		displayed_count += 1

		# Soundscape Card Container
		var card: PanelContainer = PanelContainer.new()
		card.custom_minimum_size = Vector2(250, 260)
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
		var slug: String = item.get("slug", "")
		if not slug.is_empty():
			var img_tex: ImageTexture = LibraryManager.load_soundscape_cover_texture(slug)
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

		# Author & Meta Info
		var meta_lbl: Label = Label.new()
		var track_count: int = item.get("track_count", 0)
		meta_lbl.text = "By %s • %d Tracks" % [author_str if not author_str.is_empty() else "Unknown", track_count]
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

		var btn_load: Button = Button.new()
		btn_load.text = "Load Project"
		btn_load.icon = load("res://assets/icons/play.svg")
		btn_load.expand_icon = true
		btn_load.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_load.custom_minimum_size = Vector2(0, 30)
		btn_load.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_load.pressed.connect(func(): _load_soundscape(item))
		btn_row.add_child(btn_load)

		var btn_cover: Button = Button.new()
		btn_cover.tooltip_text = "Change Cover Artwork"
		btn_cover.icon = load("res://assets/icons/image.svg")
		btn_cover.expand_icon = true
		btn_cover.custom_minimum_size = Vector2(30, 30)
		btn_cover.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_cover.pressed.connect(func(): _prompt_change_cover(slug))
		btn_row.add_child(btn_cover)

		var btn_del: Button = Button.new()
		btn_del.tooltip_text = "Delete Soundscape"
		btn_del.icon = load("res://assets/icons/trash.svg")
		btn_del.expand_icon = true
		btn_del.custom_minimum_size = Vector2(30, 30)
		btn_del.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_del.pressed.connect(func(): _delete_soundscape(item))
		btn_row.add_child(btn_del)

		items_container.add_child(card)

	if displayed_count == 0:
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No soundscapes found in library.\nPaste an ambient-mixer.com link above to download or create a new soundscape in the Studio!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 12)
		empty_lbl.add_theme_color_override("font_color", pal["text_dim"])
		items_container.add_child(empty_lbl)

func _load_soundscape(item: Dictionary) -> void:
	var path: String = item.get("path", "")
	if path.is_empty():
		return

	var project: SoundscapeData.SoundscapeProject = LibraryManager.load_soundscape(path)
	if project:
		soundscape_loaded.emit(project)

func _prompt_change_cover(slug: String) -> void:
	_selected_slug_for_cover = slug
	if cover_file_dialog:
		cover_file_dialog.popup_centered(Vector2i(650, 480))

func _on_cover_file_selected(file_path: String) -> void:
	if _selected_slug_for_cover.is_empty() or file_path.is_empty():
		return
	LibraryManager.set_soundscape_cover(_selected_slug_for_cover, file_path)
	refresh_library()

func _delete_soundscape(item: Dictionary) -> void:
	var path: String = item.get("path", "")
	if path.is_empty():
		return

	var slug: String = item.get("slug", "")
	if not slug.is_empty():
		var dir_path: String = "user://library/" + slug
		if DirAccess.dir_exists_absolute(dir_path):
			var dir: DirAccess = DirAccess.open(dir_path)
			if dir:
				dir.list_dir_begin()
				var f_name: String = dir.get_next()
				while not f_name.is_empty():
					if not dir.current_is_dir():
						dir.remove(f_name)
					f_name = dir.get_next()
				dir.list_dir_end()
			DirAccess.remove_absolute(dir_path)
	refresh_library()
