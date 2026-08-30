class_name MainView
extends Control

# Author: Adromir
# Repository: https://github.com/adromir

var current_project: SoundscapeData.SoundscapeProject = null
var spatial_engine: SpatialEngine = null

# Menu Bar
@onready var top_menu_bar: MenuBar = $Margin/RootVBox/MenuBarContainer/TopMenuBar
@onready var popup_file: PopupMenu = $Margin/RootVBox/MenuBarContainer/TopMenuBar/File
@onready var popup_edit: PopupMenu = $Margin/RootVBox/MenuBarContainer/TopMenuBar/Edit
@onready var popup_view: PopupMenu = $Margin/RootVBox/MenuBarContainer/TopMenuBar/View
@onready var popup_playback: PopupMenu = $Margin/RootVBox/MenuBarContainer/TopMenuBar/Playback
@onready var popup_help: PopupMenu = $Margin/RootVBox/MenuBarContainer/TopMenuBar/Help

# Top Transport Bar
@onready var title_edit: LineEdit = $Margin/RootVBox/TopTransportBar/ProjectTitleBox/TitleEdit
@onready var btn_set_cover: Button = $Margin/RootVBox/TopTransportBar/ProjectTitleBox/BtnSetCover
@onready var btn_save_quick: Button = $Margin/RootVBox/TopTransportBar/ProjectTitleBox/BtnSaveQuick
@onready var btn_export_quick: Button = $Margin/RootVBox/TopTransportBar/ProjectTitleBox/BtnExportQuick

@onready var btn_play: Button = $Margin/RootVBox/TopTransportBar/CenterTransport/BtnPlay
@onready var btn_stop: Button = $Margin/RootVBox/TopTransportBar/CenterTransport/BtnStop
@onready var master_vol_icon: TextureRect = $Margin/RootVBox/TopTransportBar/CenterTransport/VolumePill/Margin/HBox/MasterVolIcon if has_node("Margin/RootVBox/TopTransportBar/CenterTransport/VolumePill/Margin/HBox/MasterVolIcon") else ($Margin/RootVBox/TopTransportBar/CenterTransport/MasterVolIcon if has_node("Margin/RootVBox/TopTransportBar/CenterTransport/MasterVolIcon") else null)
@onready var master_slider: HSlider = $Margin/RootVBox/TopTransportBar/CenterTransport/VolumePill/Margin/HBox/MasterSlider if has_node("Margin/RootVBox/TopTransportBar/CenterTransport/VolumePill/Margin/HBox/MasterSlider") else ($Margin/RootVBox/TopTransportBar/CenterTransport/MasterSlider if has_node("Margin/RootVBox/TopTransportBar/CenterTransport/MasterSlider") else null)
@onready var layout_option: OptionButton = $Margin/RootVBox/TopTransportBar/CenterTransport/LayoutOption

# Nav Tabs
@onready var btn_tab_studio: Button = $Margin/RootVBox/TopTransportBar/NavTabsRow/BtnTabStudio
@onready var btn_tab_story: Button = $Margin/RootVBox/TopTransportBar/NavTabsRow/BtnTabStory
@onready var btn_tab_library: Button = $Margin/RootVBox/TopTransportBar/NavTabsRow/BtnTabLibrary

# Views Stack
@onready var studio_view: HBoxContainer = $Margin/RootVBox/ViewsStack/StudioView
@onready var story_view: PanelContainer = $Margin/RootVBox/ViewsStack/StoryView
@onready var library_view: PanelContainer = $Margin/RootVBox/ViewsStack/LibraryView

# Library Sub-views
@onready var btn_subtab_soundscapes: Button = $Margin/RootVBox/ViewsStack/LibraryView/VBox/SubTabsRow/BtnSubTabSoundscapes
@onready var btn_subtab_samples: Button = $Margin/RootVBox/ViewsStack/LibraryView/VBox/SubTabsRow/BtnSubTabSamples
@onready var soundscape_browser: PanelContainer = $Margin/RootVBox/ViewsStack/LibraryView/VBox/SoundscapeBrowser
@onready var sample_browser: PanelContainer = $Margin/RootVBox/ViewsStack/LibraryView/VBox/SampleBrowser

var _active_library_subtab: int = 0

# Studio Docks
@onready var left_dock: PanelContainer = $Margin/RootVBox/ViewsStack/StudioView/LeftDock
@onready var btn_reset_all_tracks: Button = $Margin/RootVBox/ViewsStack/StudioView/LeftDock/VBoxLeft/HeaderLeft/BtnResetAllTracks if has_node("Margin/RootVBox/ViewsStack/StudioView/LeftDock/VBoxLeft/HeaderLeft/BtnResetAllTracks") else null
@onready var btn_popout_tracks: Button = $Margin/RootVBox/ViewsStack/StudioView/LeftDock/VBoxLeft/HeaderLeft/BtnPopoutTracks
@onready var track_list_slot: MarginContainer = $Margin/RootVBox/ViewsStack/StudioView/LeftDock/VBoxLeft/TrackListSlot
@onready var track_list: TrackList = $Margin/RootVBox/ViewsStack/StudioView/LeftDock/VBoxLeft/TrackListSlot/TrackList

@onready var center_dock: PanelContainer = $Margin/RootVBox/ViewsStack/StudioView/CenterDock
@onready var btn_popout_radar: Button = $Margin/RootVBox/ViewsStack/StudioView/CenterDock/VBoxCenter/HeaderCenter/BtnPopoutRadar
@onready var spin_radius: SpinBox = $Margin/RootVBox/ViewsStack/StudioView/CenterDock/VBoxCenter/HeaderCenter/RadiusHBox/SpinRadius if has_node("Margin/RootVBox/ViewsStack/StudioView/CenterDock/VBoxCenter/HeaderCenter/RadiusHBox/SpinRadius") else null
@onready var btn_radius_dec: Button = $Margin/RootVBox/ViewsStack/StudioView/CenterDock/VBoxCenter/HeaderCenter/RadiusHBox/BtnRadiusDec if has_node("Margin/RootVBox/ViewsStack/StudioView/CenterDock/VBoxCenter/HeaderCenter/RadiusHBox/BtnRadiusDec") else null
@onready var btn_radius_inc: Button = $Margin/RootVBox/ViewsStack/StudioView/CenterDock/VBoxCenter/HeaderCenter/RadiusHBox/BtnRadiusInc if has_node("Margin/RootVBox/ViewsStack/StudioView/CenterDock/VBoxCenter/HeaderCenter/RadiusHBox/BtnRadiusInc") else null
@onready var spatial_canvas_slot: MarginContainer = $Margin/RootVBox/ViewsStack/StudioView/CenterDock/VBoxCenter/SpatialCanvasSlot
@onready var spatial_canvas: SpatialCanvas = $Margin/RootVBox/ViewsStack/StudioView/CenterDock/VBoxCenter/SpatialCanvasSlot/SpatialCanvas

@onready var right_dock: PanelContainer = $Margin/RootVBox/ViewsStack/StudioView/RightDock
@onready var btn_popout_inspector: Button = $Margin/RootVBox/ViewsStack/StudioView/RightDock/VBoxRight/HeaderRight/BtnPopoutInspector
@onready var track_inspector_slot: MarginContainer = $Margin/RootVBox/ViewsStack/StudioView/RightDock/VBoxRight/TrackInspectorSlot
@onready var track_inspector: TrackInspector = $Margin/RootVBox/ViewsStack/StudioView/RightDock/VBoxRight/TrackInspectorSlot/TrackInspector

# Story / Automation View Controls
@onready var automation_canvas: AutomationCanvas = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/AutomationCanvas
@onready var btn_toggle_path: Button = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/BtnTogglePath
@onready var btn_loop_path: Button = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/BtnLoopPath
@onready var btn_speed_dec: Button = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/BtnSpeedDec if has_node("Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/BtnSpeedDec") else null
@onready var speed_spin_box: SpinBox = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/SpeedSpinBox if has_node("Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/SpeedSpinBox") else null
@onready var btn_speed_inc: Button = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/BtnSpeedInc if has_node("Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/BtnSpeedInc") else null
@onready var path_speed_slider: HSlider = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/PathSpeedSlider if has_node("Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/PathSpeedSlider") else null
@onready var speed_kmh_label: Label = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/SpeedKmhLabel if has_node("Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/SpeedBox/SpeedKmhLabel") else null
@onready var btn_clear_path: Button = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/BtnClearPath
@onready var lbl_path_stats: Label = $Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/LblPathStats if has_node("Margin/RootVBox/ViewsStack/StoryView/StoryVBox/StoryTopBar/LblPathStats") else null

# Windows & Dialogs
@onready var about_dialog: AcceptDialog = $AboutDialog
@onready var radar_window: RadarWindow = $RadarWindow
@onready var tracks_window: TracksWindow = $TracksWindow
@onready var inspector_window: InspectorWindow = $InspectorWindow
@onready var export_dialog: ExportDialog = $ExportDialog
@onready var settings_dialog: SettingsDialog = $SettingsDialog
@onready var rate_picker_popup: RatePickerPopup = $RatePickerPopup
@onready var cover_file_dialog: FileDialog = $CoverFileDialog

var _active_tab: int = 0
var _theme_popup: PopupMenu = null
var _lang_popup: PopupMenu = null
var _speaker_popup: PopupMenu = null
var _recent_popup: PopupMenu = null
var _recent_projects: Array[Dictionary] = []
const RECENT_PROJECTS_FILE: String = "user://recent_projects.json"
const CLEAR_RECENT_ID: int = 9999

# Menu Action IDs
enum MenuFileAction { NEW, OPEN, SAVE, SAVE_AS, EXPORT, IMPORT, PREFERENCES, EXIT }
enum MenuEditAction { ADD_TRACK, CLEAR_TRACKS, RESET_PATH, RESET_SELECTED_STEM, RESET_ALL_STEMS }
enum MenuViewAction { TAB_STUDIO, TAB_STORY, TAB_SAMPLES, OPEN_LIBRARY, FULLSCREEN }
enum MenuPlaybackAction { PLAY, PAUSE, STOP }
enum MenuHelpAction { ABOUT, DOCS, GITHUB }

func _ready() -> void:
	position = Vector2.ZERO
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if has_node("Background"): $Background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if has_node("Margin"): $Margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

	spatial_engine = SpatialEngine.new()
	spatial_engine.name = "SpatialEngine"
	add_child(spatial_engine)

	spatial_engine.track_triggered.connect(func(id: String):
		if spatial_canvas: spatial_canvas.trigger_pulse(id)
	)

	DisplayServer.window_set_title("3D Soundscape Studio")
	get_window().files_dropped.connect(_on_window_files_dropped)
	_load_recent_projects()
	_setup_menu_bar()
	_populate_speaker_layouts()
	_connect_signals()
	_load_workspace_settings()
	_switch_tab(0)
	_create_new_project("New Soundscape")
	update_localization()

func _on_viewport_size_changed() -> void:
	_update_dock_layout()
	if spatial_canvas and spatial_canvas.is_inside_tree():
		spatial_canvas.queue_redraw()

func _setup_menu_bar() -> void:
	if top_menu_bar == null:
		return

	# Update Menu Titles on the MenuBar
	top_menu_bar.set_menu_title(0, LocalizationData.tr_key("MENU_FILE"))
	top_menu_bar.set_menu_title(1, LocalizationData.tr_key("MENU_EDIT"))
	top_menu_bar.set_menu_title(2, LocalizationData.tr_key("MENU_VIEW"))
	top_menu_bar.set_menu_title(3, LocalizationData.tr_key("MENU_PLAYBACK"))
	top_menu_bar.set_menu_title(4, LocalizationData.tr_key("MENU_HELP"))

	# 1. FILE POPUP
	if popup_file:
		popup_file.clear()
		popup_file.add_item("New Soundscape", MenuFileAction.NEW, KEY_MASK_CTRL | KEY_N)
		popup_file.add_item("Open Soundscape...", MenuFileAction.OPEN, KEY_MASK_CTRL | KEY_O)

		# Submenu Recent Projects
		if _recent_popup == null:
			_recent_popup = PopupMenu.new()
			_recent_popup.name = "RecentSubmenu"
			_recent_popup.id_pressed.connect(_on_recent_menu_id_pressed)
			popup_file.add_child(_recent_popup)
		_rebuild_recent_menu()
		popup_file.add_submenu_node_item(LocalizationData.tr_key("MENU_FILE_RECENT"), _recent_popup)

		popup_file.add_separator()
		popup_file.add_item("Save Soundscape", MenuFileAction.SAVE, KEY_MASK_CTRL | KEY_S)
		popup_file.add_item("Save Soundscape As...", MenuFileAction.SAVE_AS, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
		popup_file.add_separator()
		popup_file.add_item("Export Audio Mix...", MenuFileAction.EXPORT, KEY_MASK_CTRL | KEY_E)
		popup_file.add_item("Import from Ambient-Mixer...", MenuFileAction.IMPORT, KEY_MASK_CTRL | KEY_I)
		popup_file.add_separator()
		popup_file.add_item("Preferences...", MenuFileAction.PREFERENCES, KEY_MASK_CTRL | KEY_COMMA)
		popup_file.add_separator()
		popup_file.add_item("Exit", MenuFileAction.EXIT, KEY_MASK_ALT | KEY_F4)
		if not popup_file.id_pressed.is_connected(_on_file_menu_id_pressed):
			popup_file.id_pressed.connect(_on_file_menu_id_pressed)

	# 2. EDIT POPUP
	if popup_edit:
		popup_edit.clear()
		popup_edit.add_item("Add Audio Track...", MenuEditAction.ADD_TRACK, KEY_MASK_CTRL | KEY_T)
		popup_edit.add_item("Clear All Audio Tracks", MenuEditAction.CLEAR_TRACKS)
		popup_edit.add_separator()
		popup_edit.add_item("Reset Selected Stem", MenuEditAction.RESET_SELECTED_STEM, KEY_MASK_CTRL | KEY_R)
		popup_edit.add_item("Reset All Stems", MenuEditAction.RESET_ALL_STEMS, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_R)
		popup_edit.add_separator()
		popup_edit.add_item("Reset Listener Path", MenuEditAction.RESET_PATH)
		if not popup_edit.id_pressed.is_connected(_on_edit_menu_id_pressed):
			popup_edit.id_pressed.connect(_on_edit_menu_id_pressed)

	# 3. VIEW POPUP
	if popup_view:
		popup_view.clear()
		popup_view.add_item("Studio Radar View", MenuViewAction.TAB_STUDIO, KEY_F1)
		popup_view.add_item("Listener Automation", MenuViewAction.TAB_STORY, KEY_F2)
		popup_view.add_item("Audio Samples", MenuViewAction.TAB_SAMPLES, KEY_F3)
		popup_view.add_separator()
		popup_view.add_item("Soundscape Library...", MenuViewAction.OPEN_LIBRARY, KEY_F4)
		popup_view.add_separator()

		# Submenu Themes
		if _theme_popup == null:
			_theme_popup = PopupMenu.new()
			_theme_popup.name = "ThemeSubmenu"
			for key in ThemeManager.THEME_NAMES.keys():
				_theme_popup.add_radio_check_item(ThemeManager.THEME_NAMES[key], key)
			_theme_popup.id_pressed.connect(_on_theme_menu_id_pressed)
			popup_view.add_child(_theme_popup)
		_sync_theme_menu_checks()
		popup_view.add_submenu_node_item("Thematic Style", _theme_popup)

		# Submenu Language
		if _lang_popup == null:
			_lang_popup = PopupMenu.new()
			_lang_popup.name = "LangSubmenu"
			for key: int in LocalizationData.LANGUAGE_NAMES.keys():
				_lang_popup.add_radio_check_item(LocalizationData.LANGUAGE_NAMES[key], key)
			_lang_popup.id_pressed.connect(_on_lang_menu_id_pressed)
			popup_view.add_child(_lang_popup)
		_sync_lang_menu_checks()
		popup_view.add_submenu_node_item("Language", _lang_popup)

		popup_view.add_separator()
		popup_view.add_item("Toggle Fullscreen", MenuViewAction.FULLSCREEN, KEY_F11)
		if not popup_view.id_pressed.is_connected(_on_view_menu_id_pressed):
			popup_view.id_pressed.connect(_on_view_menu_id_pressed)

	# 4. PLAYBACK POPUP
	if popup_playback:
		popup_playback.clear()
		popup_playback.add_item("Play All Tracks", MenuPlaybackAction.PLAY, KEY_SPACE)
		popup_playback.add_item("Pause Playback", MenuPlaybackAction.PAUSE)
		popup_playback.add_item("Stop All Playback", MenuPlaybackAction.STOP)
		popup_playback.add_separator()

		# Submenu Speaker Layout
		if _speaker_popup == null:
			_speaker_popup = PopupMenu.new()
			_speaker_popup.name = "SpeakerSubmenu"
			for key: int in SpeakerLayouts.LAYOUT_NAMES.keys():
				_speaker_popup.add_radio_check_item(SpeakerLayouts.LAYOUT_NAMES[key], key)
			_speaker_popup.id_pressed.connect(_on_speaker_menu_id_pressed)
			popup_playback.add_child(_speaker_popup)
		_sync_speaker_menu_checks()
		popup_playback.add_submenu_node_item("Speaker Setup", _speaker_popup)

		if not popup_playback.id_pressed.is_connected(_on_playback_menu_id_pressed):
			popup_playback.id_pressed.connect(_on_playback_menu_id_pressed)

	# 5. HELP POPUP
	if popup_help:
		popup_help.clear()
		popup_help.add_item(LocalizationData.tr_key("MENU_HELP_WIKI"), MenuHelpAction.DOCS)
		popup_help.add_item(LocalizationData.tr_key("MENU_HELP_GITHUB"), MenuHelpAction.GITHUB)
		popup_help.add_separator()
		popup_help.add_item(LocalizationData.tr_key("MENU_HELP_ABOUT"), MenuHelpAction.ABOUT)
		if not popup_help.id_pressed.is_connected(_on_help_menu_id_pressed):
			popup_help.id_pressed.connect(_on_help_menu_id_pressed)

func _sync_theme_menu_checks() -> void:
	if _theme_popup == null: return
	for i in range(_theme_popup.item_count):
		_theme_popup.set_item_checked(i, i == ThemeManager.current_theme)

func _sync_lang_menu_checks() -> void:
	if _lang_popup == null: return
	for i in range(_lang_popup.item_count):
		_lang_popup.set_item_checked(i, i == LocalizationData.current_language)

func _sync_speaker_menu_checks() -> void:
	if _speaker_popup == null or spatial_engine == null: return
	for i in range(_speaker_popup.item_count):
		_speaker_popup.set_item_checked(i, i == spatial_engine.speaker_layout)

# ==================== RECENT PROJECTS MANAGEMENT ====================

func _load_recent_projects() -> void:
	_recent_projects.clear()
	if not FileAccess.file_exists(RECENT_PROJECTS_FILE):
		return
	var f: FileAccess = FileAccess.open(RECENT_PROJECTS_FILE, FileAccess.READ)
	if f:
		var json: JSON = JSON.new()
		if json.parse(f.get_as_text()) == OK and json.data is Array:
			for item in json.data:
				if item is Dictionary:
					_recent_projects.append(item)
		f.close()

func _save_recent_projects() -> void:
	var f: FileAccess = FileAccess.open(RECENT_PROJECTS_FILE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_recent_projects, "\t"))
		f.close()

func _add_recent_project(p_title: String, p_path: String = "", p_folder: String = "") -> void:
	if p_title.is_empty():
		return
	var clean_title: String = p_title.strip_edges()
	var new_entry: Dictionary = {
		"title": clean_title,
		"path": p_path,
		"folder_name": p_folder,
		"timestamp": int(Time.get_unix_time_from_system())
	}
	for i in range(_recent_projects.size() - 1, -1, -1):
		var p: Dictionary = _recent_projects[i]
		var match_title: bool = (p.get("title", "") == clean_title)
		var match_path: bool = (not p_path.is_empty() and p.get("path", "") == p_path)
		var match_folder: bool = (not p_folder.is_empty() and p.get("folder_name", "") == p_folder)
		if match_title or match_path or match_folder:
			_recent_projects.remove_at(i)
	_recent_projects.insert(0, new_entry)
	if _recent_projects.size() > 10:
		_recent_projects.resize(10)
	_save_recent_projects()
	_rebuild_recent_menu()

func _rebuild_recent_menu() -> void:
	if _recent_popup == null:
		return
	_recent_popup.clear()
	if _recent_projects.is_empty():
		_recent_popup.add_item(LocalizationData.tr_key("MENU_FILE_NO_RECENT"), -1)
		_recent_popup.set_item_disabled(0, true)
	else:
		for i in range(_recent_projects.size()):
			var p: Dictionary = _recent_projects[i]
			var t: String = p.get("title", "Untitled")
			_recent_popup.add_item("%d. %s" % [i + 1, t], i)
		_recent_popup.add_separator()
		_recent_popup.add_item(LocalizationData.tr_key("MENU_FILE_CLEAR_RECENT"), CLEAR_RECENT_ID)

func _on_recent_menu_id_pressed(id: int) -> void:
	if id == CLEAR_RECENT_ID:
		_recent_projects.clear()
		_save_recent_projects()
		_rebuild_recent_menu()
		return
	if id >= 0 and id < _recent_projects.size():
		var entry: Dictionary = _recent_projects[id]
		var folder_name: String = entry.get("folder_name", "")
		var p_path: String = entry.get("path", "")
		var loaded_proj: SoundscapeData.SoundscapeProject = null
		if not p_path.is_empty() and FileAccess.file_exists(ProjectSettings.globalize_path(p_path)):
			loaded_proj = LibraryManager.load_project_file(p_path)
		elif not folder_name.is_empty():
			var full_path: String = "user://library/" + folder_name + "/project.ambmix"
			loaded_proj = LibraryManager.load_project_file(full_path)
		else:
			var slug: String = AmbientMixerClient.sanitize_filename(entry.get("title", ""))
			var full_path: String = "user://library/" + slug + "/project.ambmix"
			if FileAccess.file_exists(ProjectSettings.globalize_path(full_path)):
				loaded_proj = LibraryManager.load_project_file(full_path)
		if loaded_proj:
			load_project(loaded_proj)
			_switch_tab(0)

func _on_file_menu_id_pressed(id: int) -> void:
	match id:
		MenuFileAction.NEW: _on_new_pressed()
		MenuFileAction.OPEN: _on_open_pressed()
		MenuFileAction.SAVE: _on_save_pressed()
		MenuFileAction.SAVE_AS: _on_save_as_pressed()
		MenuFileAction.EXPORT:
			if export_dialog and current_project: export_dialog.open_for_project(current_project)
		MenuFileAction.IMPORT:
			_on_open_pressed()
		MenuFileAction.PREFERENCES:
			if settings_dialog: settings_dialog.popup_centered()
		MenuFileAction.EXIT:
			get_tree().quit()

func _on_edit_menu_id_pressed(id: int) -> void:
	match id:
		MenuEditAction.ADD_TRACK:
			_on_add_track_requested()
		MenuEditAction.CLEAR_TRACKS:
			if current_project:
				current_project.tracks.clear()
				if track_list: track_list.set_project(current_project)
				if spatial_canvas: spatial_canvas.set_project(current_project)
				if spatial_engine: spatial_engine.load_project(current_project)
		MenuEditAction.RESET_SELECTED_STEM:
			if track_inspector and track_inspector.current_track:
				_on_track_reset_requested(track_inspector.current_track.id)
		MenuEditAction.RESET_ALL_STEMS:
			_on_all_tracks_reset_requested()
		MenuEditAction.RESET_PATH:
			if current_project:
				current_project.listener_path.points.clear()
				current_project.listener_path.enabled = false
				if automation_canvas: automation_canvas.queue_redraw()

func _on_view_menu_id_pressed(id: int) -> void:
	match id:
		MenuViewAction.TAB_STUDIO: _switch_tab(0)
		MenuViewAction.TAB_STORY: _switch_tab(1)
		MenuViewAction.TAB_SAMPLES: _switch_tab(2)
		MenuViewAction.OPEN_LIBRARY: _on_open_pressed()
		MenuViewAction.FULLSCREEN: _toggle_fullscreen()

func _on_playback_menu_id_pressed(id: int) -> void:
	match id:
		MenuPlaybackAction.PLAY: _toggle_play_pause()
		MenuPlaybackAction.PAUSE: if spatial_engine: spatial_engine.pause_all()
		MenuPlaybackAction.STOP: _stop_playback()

func _on_help_menu_id_pressed(id: int) -> void:
	match id:
		MenuHelpAction.DOCS:
			OS.shell_open("https://github.com/adromir/3D-Soundscape-Studio/wiki")
		MenuHelpAction.GITHUB:
			OS.shell_open("https://github.com/adromir/3D-Soundscape-Studio")
		MenuHelpAction.ABOUT:
			_show_themed_about_dialog()

func _on_theme_menu_id_pressed(id: int) -> void:
	_apply_theme(id as ThemeManager.ThemeMode)
	_sync_theme_menu_checks()
	_save_workspace_settings()

func _on_lang_menu_id_pressed(id: int) -> void:
	LocalizationData.set_language(id as LocalizationData.Language)
	_sync_lang_menu_checks()
	update_localization()
	_save_workspace_settings()

func _on_speaker_menu_id_pressed(id: int) -> void:
	if spatial_engine:
		spatial_engine.set_speaker_layout(id as SpeakerLayouts.LayoutType)
	if layout_option:
		layout_option.select(id)
	_sync_speaker_menu_checks()

func _toggle_fullscreen() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _populate_speaker_layouts() -> void:
	if layout_option == null:
		return
	layout_option.clear()
	for key: int in SpeakerLayouts.LAYOUT_NAMES.keys():
		layout_option.add_item(SpeakerLayouts.LAYOUT_NAMES[key], key)
	layout_option.item_selected.connect(func(idx: int):
		if spatial_engine:
			spatial_engine.set_speaker_layout(idx as SpeakerLayouts.LayoutType)
		_sync_speaker_menu_checks()
	)

func _connect_signals() -> void:
	# Navigation Pills
	for p in [btn_tab_studio, btn_tab_story, btn_tab_library]:
		if p:
			p.toggle_mode = true
	btn_tab_studio.pressed.connect(func(): _switch_tab(0))
	btn_tab_story.pressed.connect(func(): _switch_tab(1))
	btn_tab_library.pressed.connect(func(): _switch_tab(2))

	# Library Sub-tabs
	for b in [btn_subtab_soundscapes, btn_subtab_samples]:
		if b:
			b.toggle_mode = true
			b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if btn_subtab_soundscapes:
		btn_subtab_soundscapes.pressed.connect(func(): _switch_library_subtab(0))
	if btn_subtab_samples:
		btn_subtab_samples.pressed.connect(func(): _switch_library_subtab(1))

	for b in [btn_tab_studio, btn_tab_story, btn_tab_library, btn_save_quick, btn_export_quick, btn_play, btn_stop]:
		if b: b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if btn_set_cover:
		btn_set_cover.pressed.connect(_on_set_cover_pressed)
	if cover_file_dialog:
		cover_file_dialog.file_selected.connect(_on_cover_file_selected)

	if btn_save_quick: btn_save_quick.pressed.connect(_on_save_pressed)
	if btn_export_quick: btn_export_quick.pressed.connect(func(): if export_dialog and current_project: export_dialog.open_for_project(current_project))

	# Transport Controls (Combined Play/Pause toggle + Stop)
	if btn_play: btn_play.pressed.connect(_toggle_play_pause)
	if btn_stop: btn_stop.pressed.connect(_stop_playback)
	if spatial_engine:
		spatial_engine.playback_state_changed.connect(func(_ply: bool): _update_play_pause_ui())

	if master_slider:
		master_slider.value_changed.connect(func(val: float):
			if current_project: current_project.master_volume = val
			if spatial_engine: spatial_engine.set_master_volume(val)
		)

	# Popout Windows & Reset All
	if btn_reset_all_tracks:
		btn_reset_all_tracks.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_reset_all_tracks.pressed.connect(_on_all_tracks_reset_requested)

	if btn_popout_tracks:
		btn_popout_tracks.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_popout_tracks.pressed.connect(_undock_tracks)
	if tracks_window:
		tracks_window.redock_requested.connect(_dock_tracks_back)
		tracks_window.size_changed.connect(_save_workspace_settings)

	if btn_popout_radar:
		btn_popout_radar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_popout_radar.pressed.connect(_undock_radar)
	if radar_window:
		radar_window.redock_requested.connect(_dock_radar_back)
		radar_window.size_changed.connect(_save_workspace_settings)

	if btn_popout_inspector:
		btn_popout_inspector.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_popout_inspector.pressed.connect(_undock_inspector)
	if inspector_window:
		inspector_window.redock_requested.connect(_dock_inspector_back)
		inspector_window.size_changed.connect(_save_workspace_settings)

	if title_edit:
		title_edit.text_changed.connect(func(new_title: String):
			if current_project:
				current_project.title = new_title
		)

	if track_list:
		track_list.track_selected.connect(_on_track_selected)
		track_list.track_volume_changed.connect(_on_track_volume_changed)
		track_list.track_mute_toggled.connect(_on_track_mute_toggled)
		track_list.track_solo_toggled.connect(_on_track_solo_toggled)
		track_list.track_deleted.connect(_on_track_deleted)
		track_list.track_trigger_mode_changed.connect(_on_track_trigger_mode_changed)
		track_list.rate_picker_requested.connect(_on_rate_picker_requested)
		track_list.add_track_requested.connect(_on_add_track_requested)

	if spatial_canvas:
		spatial_canvas.track_selected.connect(_on_track_selected)
		spatial_canvas.track_position_changed.connect(_on_track_canvas_position_changed)
		spatial_canvas.soundspace_radius_changed.connect(func(r: float):
			if spin_radius: spin_radius.set_value_no_signal(r)
			if automation_canvas: automation_canvas.set_soundspace_max_distance(r)
		)

	if spin_radius:
		spin_radius.value_changed.connect(func(val: float):
			if current_project:
				current_project.soundspace_radius = val
			if spatial_canvas:
				spatial_canvas.set_soundspace_max_distance(val)
			if automation_canvas:
				automation_canvas.set_soundspace_max_distance(val)
		)

	if btn_radius_dec:
		btn_radius_dec.pressed.connect(func():
			if spin_radius:
				spin_radius.value = maxf(2.0, spin_radius.value - 1.0)
		)

	if btn_radius_inc:
		btn_radius_inc.pressed.connect(func():
			if spin_radius:
				spin_radius.value = minf(100.0, spin_radius.value + 1.0)
		)

	if track_inspector:
		track_inspector.track_modified.connect(_on_track_inspector_modified)
		track_inspector.rate_picker_requested.connect(_on_rate_picker_requested)
		track_inspector.track_reset_requested.connect(_on_track_reset_requested)
		track_inspector.all_tracks_reset_requested.connect(_on_all_tracks_reset_requested)

	if rate_picker_popup:
		rate_picker_popup.rate_applied.connect(_on_rate_applied)

	# Automation Canvas Controls
	if btn_toggle_path:
		btn_toggle_path.toggled.connect(func(toggled: bool):
			if current_project:
				current_project.listener_path.enabled = toggled
				_update_path_controls_ui()
				if spatial_engine: spatial_engine.set_listener_path(current_project.listener_path)
				if automation_canvas: automation_canvas.queue_redraw()
		)
	if btn_loop_path:
		btn_loop_path.toggled.connect(func(toggled: bool):
			if current_project:
				current_project.listener_path.loop = toggled
				_update_path_controls_ui()
				if spatial_engine: spatial_engine.set_listener_path(current_project.listener_path)
				if automation_canvas: automation_canvas.queue_redraw()
		)
	if speed_spin_box:
		speed_spin_box.value_changed.connect(func(val: float):
			if current_project:
				current_project.listener_path.speed = val
				if path_speed_slider: path_speed_slider.set_value_no_signal(val)
				if speed_kmh_label: speed_kmh_label.text = "(%.1f km/h)" % (val * 3.6)
				_update_path_stats()
				if spatial_engine: spatial_engine.set_listener_path(current_project.listener_path)
		)
	if path_speed_slider:
		path_speed_slider.value_changed.connect(func(val: float):
			if current_project:
				current_project.listener_path.speed = val
				if speed_spin_box: speed_spin_box.set_value_no_signal(val)
				if speed_kmh_label: speed_kmh_label.text = "(%.1f km/h)" % (val * 3.6)
				_update_path_stats()
				if spatial_engine: spatial_engine.set_listener_path(current_project.listener_path)
		)
	if btn_speed_dec:
		btn_speed_dec.pressed.connect(func():
			if speed_spin_box: speed_spin_box.value = maxf(0.1, speed_spin_box.value - 0.1)
		)
	if btn_speed_inc:
		btn_speed_inc.pressed.connect(func():
			if speed_spin_box: speed_spin_box.value = minf(10.0, speed_spin_box.value + 0.1)
		)
	if btn_clear_path:
		btn_clear_path.pressed.connect(func():
			if current_project:
				current_project.listener_path.points.clear()
				current_project.listener_path.enabled = false
				_update_path_controls_ui()
				if spatial_engine: spatial_engine.set_listener_path(current_project.listener_path)
				if automation_canvas: automation_canvas.queue_redraw()
		)
	if automation_canvas:
		automation_canvas.path_updated.connect(func():
			_update_path_controls_ui()
			if spatial_engine and current_project:
				spatial_engine.set_listener_path(current_project.listener_path)
		)
	if spatial_engine:
		spatial_engine.listener_position_updated.connect(func(_pos: Vector3, t: float):
			if automation_canvas:
				automation_canvas.set_playhead(t)
		)

	if soundscape_browser:
		soundscape_browser.soundscape_loaded.connect(func(proj: SoundscapeData.SoundscapeProject):
			load_project(proj)
			_switch_tab(0)
		)

	if sample_browser:
		sample_browser.sample_added_to_project.connect(_on_sample_added)

	if spatial_canvas:
		spatial_canvas.sample_dropped.connect(_on_canvas_sample_dropped)

	if settings_dialog:
		settings_dialog.settings_saved.connect(_on_settings_saved_sync)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_SPACE:
			var focus = get_viewport().gui_get_focus_owner()
			if not (focus is LineEdit or focus is TextEdit):
				_toggle_play_pause()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F11:
			_toggle_fullscreen()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F1:
			_switch_tab(0)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F2:
			_switch_tab(1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F3:
			_switch_tab(2, 0)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F4:
			_switch_tab(2, 1)
			get_viewport().set_input_as_handled()

func _switch_tab(idx: int, subtab_idx: int = -1) -> void:
	_active_tab = idx
	studio_view.visible = (idx == 0)
	story_view.visible = (idx == 1)
	library_view.visible = (idx == 2)

	# Highlight Active Nav Pill
	var pal: Dictionary = ThemeManager.get_palette()
	var pills: Array[Button] = [btn_tab_studio, btn_tab_story, btn_tab_library]
	for i in range(pills.size()):
		var p: Button = pills[i]
		if p:
			p.modulate = Color.WHITE
			p.set_pressed_no_signal(i == idx)
			if i == idx:
				p.add_theme_color_override("font_color", pal.get("primary", Color(0.96, 0.82, 0.48)))
			else:
				p.add_theme_color_override("font_color", pal.get("text_main", Color(0.92, 0.94, 0.96)))

	if idx == 0:
		_update_dock_layout()
	elif idx == 1 and automation_canvas and current_project:
		automation_canvas.set_project(current_project)
	elif idx == 2:
		if subtab_idx >= 0:
			_switch_library_subtab(subtab_idx)
		else:
			_switch_library_subtab(_active_library_subtab)

func _switch_library_subtab(sub_idx: int) -> void:
	_active_library_subtab = sub_idx
	if soundscape_browser:
		soundscape_browser.visible = (sub_idx == 0)
		if sub_idx == 0:
			soundscape_browser.refresh_library()
	if sample_browser:
		sample_browser.visible = (sub_idx == 1)
		if sub_idx == 1:
			sample_browser.scan_samples()

	var pal: Dictionary = ThemeManager.get_palette()
	if btn_subtab_soundscapes:
		btn_subtab_soundscapes.set_pressed_no_signal(sub_idx == 0)
		btn_subtab_soundscapes.add_theme_color_override("font_color", pal.get("primary", Color(0.96, 0.82, 0.48)) if sub_idx == 0 else pal.get("text_main", Color(0.92, 0.94, 0.96)))
	if btn_subtab_samples:
		btn_subtab_samples.set_pressed_no_signal(sub_idx == 1)
		btn_subtab_samples.add_theme_color_override("font_color", pal.get("primary", Color(0.96, 0.82, 0.48)) if sub_idx == 1 else pal.get("text_main", Color(0.92, 0.94, 0.96)))

# ==================== UNDOCK / POP-OUT HANDLING ====================

func _update_dock_layout() -> void:
	if spatial_canvas and spatial_canvas.is_inside_tree():
		spatial_canvas.queue_redraw()

func _undock_tracks() -> void:
	if track_list and tracks_window:
		left_dock.visible = false
		_update_dock_layout()
		tracks_window.embed_content(track_list)
		tracks_window.popup_centered(Vector2i(380, 560))
		_save_workspace_settings()

func _dock_tracks_back() -> void:
	if track_list and track_list_slot:
		if track_list.get_parent():
			track_list.get_parent().remove_child(track_list)
		track_list.position = Vector2.ZERO
		track_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		track_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
		track_list_slot.add_child(track_list)
		left_dock.visible = true
		_update_dock_layout()
		_save_workspace_settings()

func _undock_radar() -> void:
	if spatial_canvas and radar_window:
		center_dock.visible = false
		_update_dock_layout()
		radar_window.embed_canvas(spatial_canvas)
		radar_window.popup_centered(Vector2i(850, 750))
		_save_workspace_settings()

func _dock_radar_back() -> void:
	if spatial_canvas and spatial_canvas_slot:
		if spatial_canvas.get_parent():
			spatial_canvas.get_parent().remove_child(spatial_canvas)
		spatial_canvas.position = Vector2.ZERO
		spatial_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spatial_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
		spatial_canvas_slot.add_child(spatial_canvas)
		center_dock.visible = true
		_update_dock_layout()
		spatial_canvas.queue_redraw()
		_save_workspace_settings()

func _undock_inspector() -> void:
	if track_inspector and inspector_window:
		right_dock.visible = false
		_update_dock_layout()
		inspector_window.embed_content(track_inspector)
		inspector_window.popup_centered(Vector2i(380, 620))
		_save_workspace_settings()

func _dock_inspector_back() -> void:
	if track_inspector and track_inspector_slot:
		if track_inspector.get_parent():
			track_inspector.get_parent().remove_child(track_inspector)
		track_inspector.position = Vector2.ZERO
		track_inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		track_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
		track_inspector_slot.add_child(track_inspector)
		right_dock.visible = true
		_update_dock_layout()
		_save_workspace_settings()

func _apply_theme(mode: ThemeManager.ThemeMode) -> void:
	ThemeManager.apply_theme(get_tree().root if get_tree() else self, mode)
	var orbs: Dictionary = ThemeManager.get_orb_colors(mode)
	if has_node("Background"):
		var bg: ColorRect = $Background
		if bg.material is ShaderMaterial:
			var mat: ShaderMaterial = bg.material as ShaderMaterial
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

	if has_node("Margin/RootVBox/TopTransportBar/CenterTransport/VolumePill"):
		var vol_pill: PanelContainer = $Margin/RootVBox/TopTransportBar/CenterTransport/VolumePill
		var pal: Dictionary = ThemeManager.get_palette()
		var pill_sb: StyleBox
		if mode == ThemeManager.ThemeMode.ZEN and ResourceLoader.exists("res://assets/textures/zen/btn_slate_normal.png"):
			var b_tex: StyleBoxTexture = StyleBoxTexture.new()
			b_tex.texture = load("res://assets/textures/zen/btn_slate_normal.png")
			b_tex.texture_margin_left = 10
			b_tex.texture_margin_right = 10
			b_tex.texture_margin_top = 10
			b_tex.texture_margin_bottom = 10
			b_tex.content_margin_left = 8
			b_tex.content_margin_right = 8
			b_tex.content_margin_top = 4
			b_tex.content_margin_bottom = 4
			pill_sb = b_tex
		else:
			var b_flat: StyleBoxFlat = StyleBoxFlat.new()
			b_flat.bg_color = pal["btn_normal"]
			b_flat.border_color = pal["panel_border"]
			b_flat.set_border_width_all(1)
			b_flat.set_corner_radius_all(5)
			b_flat.content_margin_left = 8
			b_flat.content_margin_right = 8
			b_flat.content_margin_top = 4
			b_flat.content_margin_bottom = 4
			pill_sb = b_flat
		vol_pill.add_theme_stylebox_override("panel", pill_sb)

	if soundscape_browser and soundscape_browser.has_method("apply_theme"):
		soundscape_browser.apply_theme(mode)
	if sample_browser and sample_browser.has_method("apply_theme"):
		sample_browser.apply_theme(mode)
	if settings_dialog and settings_dialog.has_method("apply_theme"):
		settings_dialog.apply_theme(mode)
	if export_dialog and export_dialog.has_method("apply_theme"):
		export_dialog.apply_theme(mode)
	if tracks_window: ThemeManager.apply_theme(tracks_window, mode)
	if radar_window: ThemeManager.apply_theme(radar_window, mode)
	if inspector_window: ThemeManager.apply_theme(inspector_window, mode)

	if track_list: track_list.set_project(current_project)
	if track_inspector and track_inspector.current_track:
		track_inspector.inspect_track(track_inspector.current_track)

	if spatial_canvas: spatial_canvas.queue_redraw()
	if automation_canvas: automation_canvas.queue_redraw()
	_switch_tab(_active_tab)

func _on_sample_added(sample_name: String, path: String) -> void:
	if current_project == null:
		return
	var track: SoundscapeData.TrackConfig = SoundscapeData.TrackConfig.new()
	track.id = "track_%d_%d" % [Time.get_ticks_msec(), randi() % 1000]
	track.name = sample_name
	track.file_path = path
	track.volume = 0.8
	track.azimuth = randf_range(-180.0, 180.0)
	track.distance = randf_range(1.5, 4.0)
	current_project.tracks.append(track)
	if track_list: track_list.set_project(current_project)
	if spatial_canvas: spatial_canvas.set_project(current_project)
	if spatial_engine: spatial_engine.load_project(current_project)
	_on_track_selected(track.id)
	_switch_tab(0)

func update_localization() -> void:
	_setup_menu_bar()

	if btn_set_cover:
		if current_project == null or current_project.cover_image_path.is_empty():
			btn_set_cover.text = LocalizationData.tr_key("BTN_SET_COVER")
		btn_set_cover.tooltip_text = LocalizationData.tr_key("TOOLTIP_SET_COVER")

	if btn_save_quick: btn_save_quick.text = LocalizationData.tr_key("BTN_SAVE")
	if btn_export_quick: btn_export_quick.text = LocalizationData.tr_key("BTN_EXPORT")
	if btn_tab_library: btn_tab_library.text = LocalizationData.tr_key("BTN_LIBRARY")
	if btn_subtab_soundscapes: btn_subtab_soundscapes.text = LocalizationData.tr_key("TAB_SOUNDSCAPES")
	if btn_subtab_samples: btn_subtab_samples.text = LocalizationData.tr_key("TAB_SAMPLES")
	if btn_play: btn_play.tooltip_text = LocalizationData.tr_key("TOOLTIP_PLAY")
	if btn_stop: btn_stop.tooltip_text = LocalizationData.tr_key("TOOLTIP_STOP")
	if master_slider: master_slider.tooltip_text = LocalizationData.tr_key("TOOLTIP_MASTER_VOL")
	if layout_option: layout_option.tooltip_text = LocalizationData.tr_key("TOOLTIP_LAYOUT")

	if track_list: track_list.update_localization()
	if track_inspector: track_inspector.update_localization()
	if soundscape_browser: soundscape_browser.update_localization()
	if sample_browser and sample_browser.has_method("update_localization"): sample_browser.update_localization()
	if export_dialog: export_dialog.update_localization()
	if settings_dialog: settings_dialog.update_localization()

func _create_new_project(title: String) -> void:
	var proj: SoundscapeData.SoundscapeProject = SoundscapeData.SoundscapeProject.new()
	proj.title = title
	proj.tracks = []
	load_project(proj, false)

func load_project(proj: SoundscapeData.SoundscapeProject, record_recent: bool = true) -> void:
	current_project = proj
	if record_recent and current_project and not current_project.title.is_empty() and not current_project.source_path.is_empty():
		_add_recent_project(current_project.title, current_project.source_path)

	if title_edit:
		title_edit.text = current_project.title

	if btn_set_cover:
		if not current_project.cover_image_path.is_empty():
			btn_set_cover.text = current_project.cover_image_path.get_file()
		else:
			btn_set_cover.text = LocalizationData.tr_key("BTN_SET_COVER")

	if track_list: track_list.set_project(current_project)
	if spatial_canvas: spatial_canvas.set_project(current_project)
	if spatial_engine: spatial_engine.load_project(current_project)
	if automation_canvas: automation_canvas.set_project(current_project)
	if spin_radius: spin_radius.set_value_no_signal(current_project.soundspace_radius)
	_update_path_controls_ui()

	if not current_project.tracks.is_empty():
		_on_track_selected(current_project.tracks[0].id)
	else:
		if track_inspector: track_inspector.inspect_track(null)

func _update_path_controls_ui() -> void:
	if current_project == null: return
	var path: SoundscapeData.ListenerPathConfig = current_project.listener_path
	
	if btn_toggle_path:
		btn_toggle_path.button_pressed = path.enabled
		btn_toggle_path.text = "Path: Active (Moving)" if path.enabled else "Path: Disabled (Center)"
	
	if btn_loop_path:
		btn_loop_path.button_pressed = path.loop
		btn_loop_path.text = "Mode: Closed Loop" if path.loop else "Mode: Open Path"
	
	if speed_spin_box:
		speed_spin_box.set_value_no_signal(path.speed)
	if path_speed_slider:
		path_speed_slider.set_value_no_signal(path.speed)
	if speed_kmh_label:
		speed_kmh_label.text = "(%.1f km/h)" % (path.speed * 3.6)
	
	_update_path_stats()

func _update_path_stats() -> void:
	if current_project == null or lbl_path_stats == null: return
	var path: SoundscapeData.ListenerPathConfig = current_project.listener_path
	var pts: Array[Vector3] = path.points
	var pt_count: int = pts.size()
	
	var total_len: float = 0.0
	for i in range(pt_count - 1):
		total_len += pts[i].distance_to(pts[i + 1])
	if path.loop and pt_count > 2:
		total_len += pts[pt_count - 1].distance_to(pts[0])
	
	var duration_sec: float = total_len / maxf(path.speed, 0.05) if pt_count >= 2 else 0.0
	lbl_path_stats.text = "%d Waypoints | %.1fm | %.1fs" % [pt_count, total_len, duration_sec]

func _on_track_selected(track_id: String) -> void:
	if track_list: track_list.select_track(track_id)
	if spatial_canvas: spatial_canvas.select_track(track_id)
	var track: SoundscapeData.TrackConfig = _find_track(track_id)
	if track_inspector: track_inspector.inspect_track(track)

func _on_track_canvas_position_changed(track_id: String, azimuth: float, elevation: float, distance: float) -> void:
	var track: SoundscapeData.TrackConfig = _find_track(track_id)
	if track:
		track.azimuth = azimuth
		track.elevation = elevation
		track.distance = distance
		if spatial_engine: spatial_engine.update_track_spatial_position(track)
		if track_inspector and track_inspector.current_track == track:
			track_inspector.sync_from_track()

func _on_track_inspector_modified(track_val: Variant) -> void:
	var track: SoundscapeData.TrackConfig = track_val if track_val is SoundscapeData.TrackConfig else _find_track(str(track_val))
	if track == null: return
	if spatial_engine:
		spatial_engine.update_track_spatial_position(track)
		spatial_engine.update_track_volume(track)
		spatial_engine.reload_track_stream(track)
	if spatial_canvas: spatial_canvas.queue_redraw()
	if track_list: track_list.rebuild_list()

func _on_track_reset_requested(track_id: String) -> void:
	var track: SoundscapeData.TrackConfig = _find_track(track_id)
	if track:
		track.reset_to_initial()
		if spatial_engine:
			spatial_engine.reload_track_stream(track)
			spatial_engine.update_track_spatial_position(track)
			spatial_engine.update_track_volume(track)
		if track_inspector and track_inspector.current_track == track:
			track_inspector.inspect_track(track)
		if track_list:
			track_list.rebuild_list()
		if spatial_canvas:
			spatial_canvas.queue_redraw()

func _on_all_tracks_reset_requested() -> void:
	if current_project == null: return
	for track in current_project.tracks:
		track.reset_to_initial()
		if spatial_engine:
			spatial_engine.reload_track_stream(track)
			spatial_engine.update_track_spatial_position(track)
			spatial_engine.update_track_volume(track)
	if track_inspector and track_inspector.current_track:
		track_inspector.inspect_track(track_inspector.current_track)
	if track_list:
		track_list.rebuild_list()
	if spatial_canvas:
		spatial_canvas.queue_redraw()

func _on_track_trigger_mode_changed(track_id: String) -> void:
	var track: SoundscapeData.TrackConfig = _find_track(track_id)
	if track == null: return
	if spatial_engine:
		spatial_engine.reload_track_stream(track)
	if track_inspector and track_inspector.current_track == track:
		track_inspector.inspect_track(track)

func _on_rate_picker_requested(track_id: String) -> void:
	var track: SoundscapeData.TrackConfig = _find_track(track_id)
	if track and rate_picker_popup:
		rate_picker_popup.open_for_track(track)

func _on_rate_applied(track_id: String, counter: int, unit_str: String) -> void:
	var track: SoundscapeData.TrackConfig = _find_track(track_id)
	if track:
		track.trigger.mode = SoundscapeData.TriggerMode.RANDOM_INTERVAL
		track.trigger.set_from_rate_unit(counter, unit_str)
		if spatial_engine:
			spatial_engine.reload_track_stream(track)
		if track_inspector and track_inspector.current_track == track:
			track_inspector.inspect_track(track)
		if track_list:
			track_list.rebuild_list()

func _on_track_volume_changed(track_id: String, vol_linear: float) -> void:
	var track: SoundscapeData.TrackConfig = _find_track(track_id)
	if track:
		track.volume = vol_linear
		if spatial_engine: spatial_engine.update_track_volume(track)
		if track_inspector and track_inspector.current_track == track:
			track_inspector.sync_from_track()

func _on_track_mute_toggled(track_id: String, muted: bool) -> void:
	var track: SoundscapeData.TrackConfig = _find_track(track_id)
	if track:
		track.muted = muted
		if spatial_engine: spatial_engine.update_track_volume(track)

func _on_track_solo_toggled(track_id: String, solo: bool) -> void:
	var track: SoundscapeData.TrackConfig = _find_track(track_id)
	if track:
		track.solo = solo
		if spatial_engine:
			for t in current_project.tracks:
				spatial_engine.update_track_volume(t)

func _on_track_deleted(track_id: String) -> void:
	if current_project == null: return
	for i in range(current_project.tracks.size()):
		if current_project.tracks[i].id == track_id:
			current_project.tracks.remove_at(i)
			break
	if spatial_engine: spatial_engine.remove_track(track_id)
	if track_list: track_list.set_project(current_project)
	if spatial_canvas: spatial_canvas.set_project(current_project)
	if track_inspector and track_inspector.current_track and track_inspector.current_track.id == track_id:
		track_inspector.inspect_track(null)

func _on_add_track_requested() -> void:
	if current_project == null: return
	var track: SoundscapeData.TrackConfig = SoundscapeData.TrackConfig.new()
	track.id = "track_%d_%d" % [Time.get_ticks_msec(), randi() % 1000]
	track.name = "Stem %d" % (current_project.tracks.size() + 1)
	track.azimuth = randf_range(-180.0, 180.0)
	track.distance = randf_range(1.0, 5.0)
	track.volume = 1.0
	current_project.tracks.append(track)

	if track_list: track_list.set_project(current_project)
	if spatial_canvas: spatial_canvas.set_project(current_project)
	if spatial_engine: spatial_engine.load_project(current_project)
	_on_track_selected(track.id)

func _find_track(track_id: String) -> SoundscapeData.TrackConfig:
	if current_project == null: return null
	for t in current_project.tracks:
		if t.id == track_id: return t
	return null

# ==================== FILE ACTIONS ====================

func _on_new_pressed() -> void:
	_create_new_project("New Soundscape")

func _on_open_pressed() -> void:
	_switch_tab(2, 0)

func _on_set_cover_pressed() -> void:
	if cover_file_dialog:
		cover_file_dialog.title = LocalizationData.tr_key("DLG_COVER_TITLE")
		ThemeManager.apply_theme(cover_file_dialog, ThemeManager.current_theme)
		cover_file_dialog.popup_centered(Vector2i(750, 500))

func _on_cover_file_selected(path: String) -> void:
	if current_project == null: return
	current_project.cover_image_path = path
	if btn_set_cover:
		btn_set_cover.text = path.get_file()
	print("✔ Selected cover image: ", path)

func _on_canvas_sample_dropped(s_name: String, s_path: String, azimuth: float, distance: float) -> void:
	if current_project == null: return
	var track: SoundscapeData.TrackConfig = current_project.add_track(s_name, s_path)
	track.azimuth = azimuth
	track.distance = distance
	if track_list: track_list.set_project(current_project)
	if spatial_canvas:
		spatial_canvas.set_project(current_project)
		spatial_canvas.select_track(track.id)
	if spatial_engine: spatial_engine.load_project(current_project)
	if track_inspector: track_inspector.set_track(track)

func _on_window_files_dropped(files: PackedStringArray) -> void:
	for file in files:
		var lower: String = file.to_lower()
		if lower.ends_with(".wav") or lower.ends_with(".mp3") or lower.ends_with(".ogg") or lower.ends_with(".flac"):
			if _active_tab == 2 and _active_library_subtab == 1 and sample_browser:
				sample_browser._on_files_imported(PackedStringArray([file]))
			else:
				var s_name: String = file.get_file().get_basename().replace("_", " ").capitalize()
				_on_sample_added(s_name, file)
		elif lower.ends_with(".png") or lower.ends_with(".jpg") or lower.ends_with(".jpeg") or lower.ends_with(".webp"):
			_on_cover_file_selected(file)

func _toggle_play_pause() -> void:
	if spatial_engine == null: return
	if spatial_engine.is_playing:
		spatial_engine.pause_all()
	else:
		spatial_engine.play_all()
	_update_play_pause_ui()

func _stop_playback() -> void:
	if spatial_engine:
		spatial_engine.stop_all()
	_update_play_pause_ui()

func _update_play_pause_ui() -> void:
	if btn_play == null: return
	var is_ply: bool = (spatial_engine != null and spatial_engine.is_playing)
	btn_play.icon = load("res://assets/icons/pause.svg") if is_ply else load("res://assets/icons/play.svg")
	btn_play.tooltip_text = "Pause Playback (Space)" if is_ply else "Play All Tracks (Space)"

func _on_settings_saved_sync() -> void:
	if settings_dialog == null: return
	var data: Dictionary = settings_dialog.load_settings()
	if data.has("speaker_layout") and spatial_engine:
		var l_idx: int = int(data["speaker_layout"])
		spatial_engine.set_speaker_layout(l_idx as SpeakerLayouts.LayoutType)
		if layout_option: layout_option.select(l_idx)
	if data.has("radar_animation") and spatial_canvas:
		spatial_canvas.set_radar_sweep_enabled(bool(data["radar_animation"]))
	if data.has("language"):
		var lang_val = data["language"]
		var lang_enum: LocalizationData.Language = LocalizationData.Language.EN
		if str(lang_val) in ["DE", "1"]: lang_enum = LocalizationData.Language.DE
		elif str(lang_val) in ["FR", "2"]: lang_enum = LocalizationData.Language.FR
		elif str(lang_val) in ["ES", "3"]: lang_enum = LocalizationData.Language.ES
		elif str(lang_val) in ["IT", "4"]: lang_enum = LocalizationData.Language.IT
		LocalizationData.set_language(lang_enum)
		_sync_lang_menu_checks()
		update_localization()
	if data.has("theme"):
		var th_val = data["theme"]
		var th_mode: ThemeManager.ThemeMode = ThemeManager.ThemeMode.ZEN
		if str(th_val) in ["0", "DARK"]: th_mode = ThemeManager.ThemeMode.DARK
		elif str(th_val) in ["1", "LIGHT"]: th_mode = ThemeManager.ThemeMode.LIGHT
		elif str(th_val) in ["2", "CYBERPUNK"]: th_mode = ThemeManager.ThemeMode.CYBERPUNK
		elif str(th_val) in ["3", "ZEN"]: th_mode = ThemeManager.ThemeMode.ZEN
		_apply_theme(th_mode)
		_sync_theme_menu_checks()
	_sync_speaker_menu_checks()

static func get_app_version() -> String:
	if FileAccess.file_exists("res://version.txt"):
		var f: FileAccess = FileAccess.open("res://version.txt", FileAccess.READ)
		if f:
			var v: String = f.get_as_text().strip_edges()
			if not v.is_empty():
				return v
	var proj_ver: String = str(ProjectSettings.get_setting("application/config/version", ""))
	if not proj_ver.is_empty():
		return proj_ver
	return "v2.0.0"

func _show_themed_about_dialog() -> void:
	var win: Window = Window.new()
	win.title = ""
	win.size = Vector2i(540, 520)
	win.exclusive = true
	win.transient = true
	win.borderless = true
	win.transparent = true
	win.transparent_bg = true
	win.close_requested.connect(win.queue_free)
	add_child(win)
	win.popup_centered()

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
	win.add_child(panel)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	panel.add_child(main_vbox)

	# --- SOLID TITLE BAR HEADER ---
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
	header_sb.content_margin_top = 10
	header_sb.content_margin_bottom = 10
	header_panel.add_theme_stylebox_override("panel", header_sb)
	main_vbox.add_child(header_panel)

	var header_hbox: HBoxContainer = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	header_panel.add_child(header_hbox)

	var title_lbl: Label = Label.new()
	title_lbl.text = "About 3D Soundscape Studio"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", pal["primary"])
	header_hbox.add_child(title_lbl)

	var btn_close: Button = Button.new()
	btn_close.text = "✕"
	btn_close.custom_minimum_size = Vector2(24, 24)
	btn_close.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close.pressed.connect(win.queue_free)
	header_hbox.add_child(btn_close)

	# --- CONTENT MARGIN ---
	var margin: MarginContainer = MarginContainer.new()
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 16)
	main_vbox.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var app_title: Label = Label.new()
	app_title.text = "3D Soundscape Studio"
	app_title.add_theme_font_size_override("font_size", 15)
	app_title.add_theme_color_override("font_color", pal["primary"])
	vbox.add_child(app_title)

	var ver_lbl: Label = Label.new()
	ver_lbl.text = "Version %s  •  Author: Adromir" % get_app_version()
	ver_lbl.add_theme_font_size_override("font_size", 11)
	ver_lbl.add_theme_color_override("font_color", pal["text_dim"])
	vbox.add_child(ver_lbl)

	var links_row: HBoxContainer = HBoxContainer.new()
	links_row.add_theme_constant_override("separation", 12)
	vbox.add_child(links_row)

	var link_btn: LinkButton = LinkButton.new()
	link_btn.text = "GitHub Repository"
	link_btn.uri = "https://github.com/adromir/3D-Soundscape-Studio"
	link_btn.add_theme_font_size_override("font_size", 11)
	link_btn.add_theme_color_override("font_color", pal["primary"])
	links_row.add_child(link_btn)

	var link_sep: Label = Label.new()
	link_sep.text = "•"
	link_sep.add_theme_font_size_override("font_size", 11)
	link_sep.add_theme_color_override("font_color", pal["text_dim"])
	links_row.add_child(link_sep)

	var wiki_btn: LinkButton = LinkButton.new()
	wiki_btn.text = "Wiki & Documentation"
	wiki_btn.uri = "https://github.com/adromir/3D-Soundscape-Studio/wiki"
	wiki_btn.add_theme_font_size_override("font_size", 11)
	wiki_btn.add_theme_color_override("font_color", pal["primary"])
	links_row.add_child(wiki_btn)

	var desc_lbl: Label = Label.new()
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.text = "An advanced Spatial & Multi-Channel Audio Workstation featuring 3D HRTF simulation, interval schedulers, dynamic listener motion paths, organic tactile UI themes, and native offline FFmpeg surround export."
	desc_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(desc_lbl)

	var lic_box: VBoxContainer = VBoxContainer.new()
	lic_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lic_box.add_theme_constant_override("separation", 4)
	vbox.add_child(lic_box)

	var lic_title: Label = Label.new()
	lic_title.text = "MIT License"
	lic_title.add_theme_font_size_override("font_size", 12)
	lic_box.add_child(lic_title)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 140)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lic_box.add_child(scroll)

	var lic_text: Label = Label.new()
	lic_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lic_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lic_text.add_theme_font_size_override("font_size", 10)
	lic_text.add_theme_color_override("font_color", pal["text_dim"])
	lic_text.text = """Copyright (c) 2026 Adromir (https://github.com/adromir)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."""
	scroll.add_child(lic_text)

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(btn_row)

	var close_btn: Button = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(80, 28)
	close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_btn.pressed.connect(win.queue_free)
	btn_row.add_child(close_btn)

	ThemeManager.apply_theme(win, ThemeManager.current_theme)
	panel.add_theme_stylebox_override("panel", outer_sb)
	header_panel.add_theme_stylebox_override("panel", header_sb)

func _on_save_pressed() -> void:
	if current_project == null: return
	var title: String = title_edit.text.strip_edges() if title_edit else "New Soundscape"
	if title.is_empty(): title = "New Soundscape"
	current_project.title = title
	var saved_path: String = LibraryManager.save_soundscape(current_project)
	print("✔ Project saved to Library: ", saved_path)
	_add_recent_project(title, saved_path)
	if soundscape_browser: soundscape_browser.refresh_library()

func _on_save_as_pressed() -> void:
	if current_project == null: return
	var title: String = title_edit.text.strip_edges() if title_edit else "New Soundscape"
	if title.is_empty(): title = "New Soundscape"
	current_project.title = title
	var new_folder: String = AmbientMixerClient.sanitize_filename(title)
	var saved_path: String = LibraryManager.save_soundscape(current_project, new_folder)
	print("✔ Project saved as: ", saved_path)
	_add_recent_project(title, saved_path, new_folder)
	if soundscape_browser: soundscape_browser.refresh_library()

func _save_workspace_settings() -> void:
	var existing_data: Dictionary = {}
	if FileAccess.file_exists("user://settings.json"):
		var fr: FileAccess = FileAccess.open("user://settings.json", FileAccess.READ)
		if fr:
			var json = JSON.new()
			if json.parse(fr.get_as_text()) == OK and json.data is Dictionary:
				existing_data = json.data
			fr.close()

	existing_data["theme"] = ThemeManager.current_theme
	existing_data["language"] = LocalizationData.current_language
	existing_data["speaker_layout"] = spatial_engine.speaker_layout if spatial_engine else 0
	existing_data["tracks_undocked"] = tracks_window.visible if tracks_window else false
	existing_data["radar_undocked"] = radar_window.visible if radar_window else false
	existing_data["inspector_undocked"] = inspector_window.visible if inspector_window else false

	if tracks_window:
		existing_data["tracks_pos"] = [tracks_window.position.x, tracks_window.position.y]
		existing_data["tracks_size"] = [tracks_window.size.x, tracks_window.size.y]
	if radar_window:
		existing_data["radar_pos"] = [radar_window.position.x, radar_window.position.y]
		existing_data["radar_size"] = [radar_window.size.x, radar_window.size.y]
	if inspector_window:
		existing_data["inspector_pos"] = [inspector_window.position.x, inspector_window.position.y]
		existing_data["inspector_size"] = [inspector_window.size.x, inspector_window.size.y]

	var f: FileAccess = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(existing_data, "\t"))
		f.close()

func _load_workspace_settings() -> void:
	if not FileAccess.file_exists("user://settings.json"):
		_apply_theme(ThemeManager.current_theme)
		return
	var f: FileAccess = FileAccess.open("user://settings.json", FileAccess.READ)
	if f == null:
		_apply_theme(ThemeManager.current_theme)
		return
	var txt: String = f.get_as_text()
	f.close()

	var test_json_conv = JSON.new()
	if test_json_conv.parse(txt) != OK:
		_apply_theme(ThemeManager.current_theme)
		return
	var data: Dictionary = test_json_conv.get_data()

	if data.has("theme"):
		_apply_theme(int(data["theme"]) as ThemeManager.ThemeMode)
	else:
		_apply_theme(ThemeManager.current_theme)
	if data.has("language"):
		var l_val = data["language"]
		var l_enum: LocalizationData.Language = LocalizationData.Language.EN
		if str(l_val) in ["DE", "1"]: l_enum = LocalizationData.Language.DE
		elif str(l_val) in ["FR", "2"]: l_enum = LocalizationData.Language.FR
		elif str(l_val) in ["ES", "3"]: l_enum = LocalizationData.Language.ES
		elif str(l_val) in ["IT", "4"]: l_enum = LocalizationData.Language.IT
		elif str(l_val) in ["EN", "0"]: l_enum = LocalizationData.Language.EN
		LocalizationData.set_language(l_enum)
	if data.has("speaker_layout") and spatial_engine:
		spatial_engine.set_speaker_layout(int(data["speaker_layout"]) as SpeakerLayouts.LayoutType)
		if layout_option: layout_option.select(int(data["speaker_layout"]))

	if data.has("radar_animation") and spatial_canvas:
		spatial_canvas.set_radar_sweep_enabled(bool(data["radar_animation"]))

	_sync_theme_menu_checks()
	_sync_lang_menu_checks()
	_sync_speaker_menu_checks()

	if data.get("tracks_undocked", false):
		_undock_tracks()
		if data.has("tracks_pos") and data["tracks_pos"] is Array and data["tracks_pos"].size() == 2:
			tracks_window.position = Vector2i(int(data["tracks_pos"][0]), int(data["tracks_pos"][1]))
		if data.has("tracks_size") and data["tracks_size"] is Array and data["tracks_size"].size() == 2:
			tracks_window.size = Vector2i(int(data["tracks_size"][0]), int(data["tracks_size"][1]))

	if data.get("radar_undocked", false):
		_undock_radar()
		if data.has("radar_pos") and data["radar_pos"] is Array and data["radar_pos"].size() == 2:
			radar_window.position = Vector2i(int(data["radar_pos"][0]), int(data["radar_pos"][1]))
		if data.has("radar_size") and data["radar_size"] is Array and data["radar_size"].size() == 2:
			radar_window.size = Vector2i(int(data["radar_size"][0]), int(data["radar_size"][1]))

	if data.get("inspector_undocked", false):
		_undock_inspector()
		if data.has("inspector_pos") and data["inspector_pos"] is Array and data["inspector_pos"].size() == 2:
			inspector_window.position = Vector2i(int(data["inspector_pos"][0]), int(data["inspector_pos"][1]))
		if data.has("inspector_size") and data["inspector_size"] is Array and data["inspector_size"].size() == 2:
			inspector_window.size = Vector2i(int(data["inspector_size"][0]), int(data["inspector_size"][1]))
