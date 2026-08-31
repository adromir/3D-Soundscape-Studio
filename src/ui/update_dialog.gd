class_name UpdateDialog
extends Window

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio


enum State { IDLE, CHECKING, UP_TO_DATE, UPDATE_AVAILABLE, DOWNLOADING, READY_TO_INSTALL, ERROR }

var _update_manager: UpdateManager = null
var _current_state: State = State.IDLE
var _release_info: Dictionary = {}
var _best_asset: Dictionary = {}
var _downloaded_file_path: String = ""

@onready var background_rect: ColorRect = $Background if has_node("Background") else null
@onready var header_panel: PanelContainer = $Margin/VBox/HeaderPanel if has_node("Margin/VBox/HeaderPanel") else null
@onready var content_panel: PanelContainer = $Margin/VBox/ContentPanel if has_node("Margin/VBox/ContentPanel") else null
@onready var status_banner: PanelContainer = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/StatusBanner if has_node("Margin/VBox/ContentPanel/ContentMargin/FormVBox/StatusBanner") else null
@onready var btn_close: Button = $Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/BtnClose if has_node("Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/BtnClose") else null

@onready var title_label: Label = $Margin/VBox/HeaderPanel/HeaderMargin/HeaderHBox/TitleLabel
@onready var headline_label: Label = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/StatusBanner/BannerMargin/BannerHBox/VersionInfoVBox/HeadlineLabel
@onready var version_compare_label: Label = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/StatusBanner/BannerMargin/BannerHBox/VersionInfoVBox/VersionCompareLabel
@onready var changelog_header_label: Label = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/ChangelogHeaderLabel
@onready var changelog_text: RichTextLabel = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/ChangelogScroll/ChangelogText
@onready var progress_bar: ProgressBar = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/ProgressBar
@onready var status_label: Label = $Margin/VBox/ContentPanel/ContentMargin/FormVBox/StatusLabel

@onready var btn_view_github: Button = $Margin/VBox/ButtonHBox/BtnViewGithub
@onready var btn_cancel: Button = $Margin/VBox/ButtonHBox/BtnCancel
@onready var btn_action: Button = $Margin/VBox/ButtonHBox/BtnAction

func _ready() -> void:
	title = LocalizationData.tr_key("DLG_UPDATE_TITLE")
	close_requested.connect(hide)

	_update_manager = UpdateManager.new()
	_update_manager.name = "UpdateManager"
	add_child(_update_manager)

	_update_manager.check_completed.connect(_on_check_completed)
	_update_manager.check_failed.connect(_on_check_failed)
	_update_manager.download_progress.connect(_on_download_progress)
	_update_manager.download_completed.connect(_on_download_completed)
	_update_manager.download_failed.connect(_on_download_failed)

	if btn_close: btn_close.pressed.connect(hide)
	if btn_cancel: btn_cancel.pressed.connect(hide)
	if btn_view_github: btn_view_github.pressed.connect(_on_view_github_pressed)
	if btn_action: btn_action.pressed.connect(_on_action_pressed)

	if changelog_text:
		changelog_text.meta_clicked.connect(func(meta):
			OS.shell_open(str(meta))
		)

	update_localization()
	apply_theme(ThemeManager.current_theme)

func apply_theme(theme_mode: ThemeManager.ThemeMode) -> void:
	var pal: Dictionary = ThemeManager.get_palette_for_mode(theme_mode)
	var orbs: Dictionary = ThemeManager.get_orb_colors(theme_mode)

	if background_rect and background_rect.material is ShaderMaterial:
		var mat: ShaderMaterial = background_rect.material as ShaderMaterial
		mat.set_shader_parameter("bg_color", orbs["bg"])
		mat.set_shader_parameter("orb1_color", orbs["orb1"])
		mat.set_shader_parameter("orb2_color", orbs["orb2"])
		mat.set_shader_parameter("orb3_color", orbs["orb3"])

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

	if status_banner:
		var b_sb: StyleBoxFlat = StyleBoxFlat.new()
		b_sb.bg_color = pal["panel_border"].lerp(pal["panel_bg"], 0.6)
		b_sb.set_border_width_all(1)
		b_sb.border_color = pal["primary"]
		b_sb.set_corner_radius_all(6)
		status_banner.add_theme_stylebox_override("panel", b_sb)

	if btn_action:
		var action_sb: StyleBoxFlat = StyleBoxFlat.new()
		action_sb.bg_color = pal["primary"]
		action_sb.set_corner_radius_all(5)
		action_sb.content_margin_left = 12
		action_sb.content_margin_right = 12
		action_sb.content_margin_top = 4
		action_sb.content_margin_bottom = 4
		btn_action.add_theme_stylebox_override("normal", action_sb)
		btn_action.add_theme_color_override("font_color", Color.WHITE)

	if title_label: title_label.add_theme_color_override("font_color", pal.get("text_main", Color.WHITE))
	if changelog_header_label: changelog_header_label.add_theme_color_override("font_color", pal.get("text_dim", Color(0.7, 0.7, 0.7)))
	if status_label and _current_state != State.ERROR and _current_state != State.READY_TO_INSTALL:
		status_label.add_theme_color_override("font_color", pal.get("text_dim", Color(0.7, 0.7, 0.7)))
	if changelog_text:
		changelog_text.add_theme_color_override("default_color", pal.get("text_main", Color.WHITE))

	ThemeManager.apply_theme(self, theme_mode)
	_refresh_state_ui()

func update_localization() -> void:
	title = LocalizationData.tr_key("DLG_UPDATE_TITLE")
	if title_label: title_label.text = LocalizationData.tr_key("DLG_UPDATE_TITLE")
	if changelog_header_label: changelog_header_label.text = LocalizationData.tr_key("UPDATE_CHANGELOG")
	if btn_view_github: btn_view_github.text = LocalizationData.tr_key("BTN_VIEW_GITHUB")

	_refresh_state_ui()

# ==================== PUBLIC API ====================

func open_and_check(silent_if_up_to_date: bool = false) -> void:
	_set_state(State.CHECKING)
	if not silent_if_up_to_date:
		popup_centered(Vector2i(620, 520))
	
	_update_manager.check_for_updates()

# ==================== STATE & UI REFRESH ====================

func _set_state(new_state: State) -> void:
	_current_state = new_state
	_refresh_state_ui()

func _refresh_state_ui() -> void:
	var pal: Dictionary = ThemeManager.get_palette()
	var curr_ver: String = UpdateManager.get_current_version()

	match _current_state:
		State.CHECKING:
			if headline_label:
				headline_label.text = LocalizationData.tr_key("UPDATE_CHECKING")
				headline_label.add_theme_color_override("font_color", pal["primary"])
			if version_compare_label:
				version_compare_label.text = "%s %s" % [LocalizationData.tr_key("UPDATE_CURRENT_VERSION"), curr_ver]
			if changelog_text:
				changelog_text.text = "[color=#8899aa]Connecting to GitHub API...[/color]"
			if progress_bar: progress_bar.visible = false
			if status_label: status_label.text = "Checking for new releases..."
			if btn_action:
				btn_action.disabled = true
				btn_action.text = LocalizationData.tr_key("BTN_DOWNLOAD_UPDATE")
			if btn_cancel: btn_cancel.text = LocalizationData.tr_key("SETTINGS_CANCEL")

		State.UP_TO_DATE:
			if headline_label:
				headline_label.text = LocalizationData.tr_key("UPDATE_UP_TO_DATE_TITLE")
				headline_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.5))
			if version_compare_label:
				version_compare_label.text = "%s %s" % [LocalizationData.tr_key("UPDATE_CURRENT_VERSION"), curr_ver]
			if changelog_text:
				var desc: String = LocalizationData.tr_key("UPDATE_UP_TO_DATE_DESC") % curr_ver
				var rel_notes: String = _release_info.get("body", "")
				if not rel_notes.is_empty():
					changelog_text.text = "[b]%s[/b]\n\n[color=#a0b0c0]%s[/color]\n\n%s" % [
						desc,
						"Latest Release Notes (%s):" % _release_info.get("tag_name", curr_ver),
						markdown_to_bbcode(rel_notes, ThemeManager.current_theme)
					]
				else:
					changelog_text.text = "[b]%s[/b]" % desc
			if progress_bar: progress_bar.visible = false
			if status_label: status_label.text = "No newer updates available."
			if btn_action:
				btn_action.disabled = false
				btn_action.text = "OK"
			if btn_cancel: btn_cancel.text = LocalizationData.tr_key("SETTINGS_CANCEL")

		State.UPDATE_AVAILABLE:
			var new_tag: String = _release_info.get("tag_name", "New Version")
			if headline_label:
				headline_label.text = LocalizationData.tr_key("UPDATE_AVAILABLE_TITLE")
				headline_label.add_theme_color_override("font_color", pal["primary"])
			if version_compare_label:
				version_compare_label.text = "%s %s  ->  %s %s" % [
					LocalizationData.tr_key("UPDATE_CURRENT_VERSION"), curr_ver,
					LocalizationData.tr_key("UPDATE_LATEST_VERSION"), new_tag
				]
			if changelog_text:
				var raw_body: String = _release_info.get("body", "No release notes provided.")
				var title_str: String = _release_info.get("title", new_tag)
				changelog_text.text = "[b][font_size=13]%s[/font_size][/b]\n\n%s" % [
					title_str,
					markdown_to_bbcode(raw_body, ThemeManager.current_theme)
				]
			if progress_bar: progress_bar.visible = false
			if status_label: status_label.text = "Update available. Click Download to start."
			if btn_action:
				btn_action.disabled = false
				btn_action.text = LocalizationData.tr_key("BTN_DOWNLOAD_UPDATE")
			if btn_cancel: btn_cancel.text = LocalizationData.tr_key("BTN_REMIND_LATER")

		State.DOWNLOADING:
			if btn_action:
				btn_action.disabled = true
				btn_action.text = "Downloading..."
			if progress_bar: progress_bar.visible = true
			if btn_cancel: btn_cancel.text = LocalizationData.tr_key("SETTINGS_CANCEL")

		State.READY_TO_INSTALL:
			if headline_label:
				headline_label.text = "Update Ready to Apply"
				headline_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.5))
			if progress_bar: progress_bar.visible = false
			if status_label:
				status_label.text = LocalizationData.tr_key("UPDATE_DOWNLOAD_COMPLETED")
				status_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.5))
			if btn_action:
				btn_action.disabled = false
				btn_action.text = LocalizationData.tr_key("BTN_INSTALL_RESTART")
			if btn_cancel: btn_cancel.text = LocalizationData.tr_key("SETTINGS_CANCEL")

		State.ERROR:
			if headline_label:
				headline_label.text = "Update Error"
				headline_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
			if progress_bar: progress_bar.visible = false
			if btn_action:
				btn_action.disabled = false
				btn_action.text = "Retry"
			if btn_cancel: btn_cancel.text = LocalizationData.tr_key("SETTINGS_CANCEL")

# ==================== SIGNAL HANDLERS ====================

func _on_check_completed(has_update: bool, release_info: Dictionary) -> void:
	_release_info = release_info
	if has_update:
		var assets: Array = release_info.get("assets", [])
		_best_asset = UpdateManager.find_best_asset_for_os(assets)
		_set_state(State.UPDATE_AVAILABLE)
		if not visible:
			popup_centered(Vector2i(620, 520))
	else:
		_set_state(State.UP_TO_DATE)

func _on_check_failed(error_message: String) -> void:
	_set_state(State.ERROR)
	if status_label:
		status_label.text = LocalizationData.tr_key("UPDATE_FAILED") % error_message
		status_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	if changelog_text:
		changelog_text.text = "[color=#ff6666]%s[/color]" % error_message

func _on_download_progress(downloaded: int, total: int, pct: float) -> void:
	if progress_bar:
		progress_bar.value = pct
	var down_mb: float = float(downloaded) / (1024.0 * 1024.0)
	var tot_mb: float = float(total) / (1024.0 * 1024.0)
	var stat_str: String = "%.1f MB / %.1f MB (%.0f%%)" % [down_mb, tot_mb, pct]
	if status_label:
		status_label.text = LocalizationData.tr_key("UPDATE_DOWNLOADING") % stat_str

func _on_download_completed(file_path: String) -> void:
	_downloaded_file_path = file_path
	_set_state(State.READY_TO_INSTALL)

func _on_download_failed(error_message: String) -> void:
	_set_state(State.ERROR)
	if status_label:
		status_label.text = LocalizationData.tr_key("UPDATE_FAILED") % error_message
		status_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

# ==================== ACTIONS ====================

func _on_action_pressed() -> void:
	match _current_state:
		State.UPDATE_AVAILABLE:
			var asset_url: String = _best_asset.get("download_url", "")
			var asset_name: String = _best_asset.get("name", "")
			if asset_url.is_empty():
				# If no direct asset matching, open release in browser
				_on_view_github_pressed()
				return
			_set_state(State.DOWNLOADING)
			_update_manager.start_download(asset_url, asset_name)

		State.READY_TO_INSTALL:
			var res: Dictionary = _update_manager.apply_update_and_restart(_downloaded_file_path)
			if res.get("is_editor", false):
				if status_label:
					status_label.text = str(res.get("message", ""))
			elif not res.get("success", true):
				if status_label:
					status_label.text = "Install error: " + str(res.get("message", ""))

		State.UP_TO_DATE:
			hide()

		State.ERROR:
			_set_state(State.CHECKING)
			_update_manager.check_for_updates()

func _on_view_github_pressed() -> void:
	var url: String = _release_info.get("html_url", "https://github.com/adromir/3D-Soundscape-Studio/releases")
	OS.shell_open(url)

# ==================== MARKDOWN TO BBCODE CONVERTER ====================

static func markdown_to_bbcode(md: String, mode: ThemeManager.ThemeMode = ThemeManager.ThemeMode.DARK) -> String:
	var out: String = md
	var is_light: bool = (mode == ThemeManager.ThemeMode.LIGHT)

	var c_h1: String = "#0d6efd" if is_light else "#fd971f"
	var c_h2: String = "#198754" if is_light else "#a6e22e"
	var c_h3: String = "#0a58ca" if is_light else "#66d9ef"
	var c_code: String = "#b02a37" if is_light else "#e6db74"

	# Replace headers ### Header
	var h3_regex: RegEx = RegEx.new()
	h3_regex.compile("(?m)^###\\s+(.+)$")
	out = h3_regex.sub(out, "[b][color=" + c_h3 + "]$1[/color][/b]", true)

	var h2_regex: RegEx = RegEx.new()
	h2_regex.compile("(?m)^##\\s+(.+)$")
	out = h2_regex.sub(out, "[b][font_size=12][color=" + c_h2 + "]$1[/color][/font_size][/b]", true)

	var h1_regex: RegEx = RegEx.new()
	h1_regex.compile("(?m)^#\\s+(.+)$")
	out = h1_regex.sub(out, "[b][font_size=14][color=" + c_h1 + "]$1[/color][/font_size][/b]", true)

	# Bold **text**
	var bold_regex: RegEx = RegEx.new()
	bold_regex.compile("\\*\\*([^*]+)\\*\\*")
	out = bold_regex.sub(out, "[b]$1[/b]", true)

	# Inline code `code`
	var code_regex: RegEx = RegEx.new()
	code_regex.compile("`([^`]+)`")
	out = code_regex.sub(out, "[code][color=" + c_code + "]$1[/color][/code]", true)

	# Bullet lists - item
	var bullet_regex: RegEx = RegEx.new()
	bullet_regex.compile("(?m)^[-*]\\s+(.+)$")
	out = bullet_regex.sub(out, "  • $1", true)

	return out
