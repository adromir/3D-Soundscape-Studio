class_name TransportBar
extends PanelContainer

# Author: Adromir
# Repository: https://github.com/adromir

signal play_pressed()
signal pause_pressed()
signal stop_pressed()
signal master_volume_changed(volume: float)
signal layout_changed(layout: SpeakerLayouts.LayoutType)
signal library_opened()
signal export_opened()
signal language_toggled()
signal theme_toggled()

@onready var btn_play: Button = $HBox/BtnPlay
@onready var btn_pause: Button = $HBox/BtnPause
@onready var btn_stop: Button = $HBox/BtnStop
@onready var master_slider: HSlider = $HBox/MasterSlider
@onready var master_label: Label = $HBox/MasterLabel
@onready var layout_option: OptionButton = $HBox/LayoutOption
@onready var btn_export: Button = $HBox/BtnExport
@onready var btn_library: Button = $HBox/BtnLibrary
@onready var btn_lang: Button = $HBox/BtnLang
@onready var btn_theme: Button = $HBox/BtnTheme
@onready var status_label: Label = $HBox/StatusLabel

func _ready() -> void:
	if btn_play:
		btn_play.icon = load("res://assets/icons/play.svg")
		btn_play.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_play.pressed.connect(func(): play_pressed.emit())
	if btn_pause:
		btn_pause.icon = load("res://assets/icons/pause.svg")
		btn_pause.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_pause.pressed.connect(func(): pause_pressed.emit())
	if btn_stop:
		btn_stop.icon = load("res://assets/icons/stop.svg")
		btn_stop.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_stop.pressed.connect(func(): stop_pressed.emit())
	if btn_library:
		btn_library.icon = load("res://assets/icons/library.svg")
		btn_library.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_library.pressed.connect(func(): library_opened.emit())
	if btn_export:
		btn_export.icon = load("res://assets/icons/export.svg")
		btn_export.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_export.pressed.connect(func(): export_opened.emit())
	if btn_lang:
		btn_lang.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_lang.pressed.connect(func(): language_toggled.emit())
	if btn_theme:
		btn_theme.icon = load("res://assets/icons/theme.svg")
		btn_theme.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_theme.pressed.connect(func(): theme_toggled.emit())

	if master_slider:
		master_slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		master_slider.value_changed.connect(func(val: float):
			master_volume_changed.emit(val)
		)

	if layout_option:
		layout_option.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		layout_option.clear()
		for key: int in SpeakerLayouts.LAYOUT_NAMES.keys():
			layout_option.add_item(SpeakerLayouts.LAYOUT_NAMES[key], key)
		layout_option.item_selected.connect(func(idx: int):
			layout_changed.emit(idx as SpeakerLayouts.LayoutType)
		)

	update_localization()

func update_localization() -> void:
	if btn_play:
		btn_play.text = LocalizationData.tr_key("BTN_PLAY")
		btn_play.tooltip_text = LocalizationData.tr_key("TOOLTIP_PLAY")
	if btn_pause:
		btn_pause.text = LocalizationData.tr_key("BTN_PAUSE")
		btn_pause.tooltip_text = LocalizationData.tr_key("TOOLTIP_PAUSE")
	if btn_stop:
		btn_stop.text = LocalizationData.tr_key("BTN_STOP")
		btn_stop.tooltip_text = LocalizationData.tr_key("TOOLTIP_STOP")
	if btn_export:
		btn_export.text = LocalizationData.tr_key("BTN_EXPORT")
	if btn_library:
		btn_library.text = LocalizationData.tr_key("BTN_LIBRARY")
	if master_label:
		master_label.text = LocalizationData.tr_key("LABEL_MASTER_VOL") + ":"
	if master_slider:
		master_slider.tooltip_text = LocalizationData.tr_key("TOOLTIP_MASTER_VOL")
	if layout_option:
		layout_option.tooltip_text = LocalizationData.tr_key("TOOLTIP_LAYOUT")
	if btn_lang:
		btn_lang.text = "DE" if LocalizationData.current_language == LocalizationData.Language.EN else "EN"
	if status_label:
		status_label.text = LocalizationData.tr_key("STATUS_READY")
	update_theme_icon()

func update_theme_icon() -> void:
	if btn_theme:
		if ThemeManager.current_theme == ThemeManager.ThemeMode.DARK:
			btn_theme.icon = load("res://assets/icons/theme.svg")
		else:
			btn_theme.icon = load("res://assets/icons/moon.svg")

func set_status(text: String) -> void:
	if status_label:
		status_label.text = text
