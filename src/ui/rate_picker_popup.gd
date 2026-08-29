class_name RatePickerPopup
extends Window

# Author: Adromir
# Repository: https://github.com/adromir

signal rate_applied(track_id: String, counter: int, unit_str: String)

const TIME_UNITS: Array[String] = [
	"1m", "5m", "10m", "15m", "30m", "1h", "2h", "4h"
]

const MAX_COUNTER: int = 60

var current_track_id: String = ""
var selected_counter: int = 1
var selected_unit: String = "1m"

@onready var panel_container: PanelContainer = $PanelContainer
@onready var count_scroll: ScrollContainer = $PanelContainer/Margin/VBox/ColumnsHBox/CountScroll
@onready var count_vbox: VBoxContainer = $PanelContainer/Margin/VBox/ColumnsHBox/CountScroll/CountVBox
@onready var unit_scroll: ScrollContainer = $PanelContainer/Margin/VBox/ColumnsHBox/UnitScroll
@onready var unit_vbox: VBoxContainer = $PanelContainer/Margin/VBox/ColumnsHBox/UnitScroll/UnitVBox

@onready var preview_label: Label = $PanelContainer/Margin/VBox/PreviewPanel/PreviewLabel
@onready var btn_ok: Button = $PanelContainer/Margin/VBox/ButtonHBox/BtnOk
@onready var btn_cancel: Button = $PanelContainer/Margin/VBox/ButtonHBox/BtnCancel

var _count_buttons: Array[Button] = []
var _unit_buttons: Array[Button] = []

func _ready() -> void:
	transient = true
	exclusive = false
	unresizable = true
	borderless = false
	title = LocalizationData.tr_key("RATE_PICKER_TITLE")
	
	_build_columns()
	_connect_buttons()
	close_requested.connect(hide)
	update_localization()

func _build_columns() -> void:
	# Build Counter Column (1 to 60)
	if count_vbox:
		for child in count_vbox.get_children():
			child.queue_free()
		_count_buttons.clear()

		for i in range(1, MAX_COUNTER + 1):
			var btn: Button = Button.new()
			btn.text = "%d" % i
			btn.custom_minimum_size = Vector2(0, 24)
			btn.flat = true
			btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.add_theme_font_size_override("font_size", 12)
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var c_val: int = i
			btn.pressed.connect(func():
				_select_counter(c_val)
			)
			count_vbox.add_child(btn)
			_count_buttons.append(btn)

	# Build Unit Column (1m, 5m, 10m, 15m, 30m, 1h, 2h, 4h)
	if unit_vbox:
		for child in unit_vbox.get_children():
			child.queue_free()
		_unit_buttons.clear()

		for u in TIME_UNITS:
			var btn: Button = Button.new()
			btn.text = u
			btn.custom_minimum_size = Vector2(0, 26)
			btn.flat = true
			btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.add_theme_font_size_override("font_size", 12)
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var u_val: String = u
			btn.pressed.connect(func():
				_select_unit(u_val)
			)
			unit_vbox.add_child(btn)
			_unit_buttons.append(btn)

func _connect_buttons() -> void:
	if btn_ok:
		btn_ok.pressed.connect(_on_ok_pressed)
	if btn_cancel:
		btn_cancel.pressed.connect(hide)

func update_localization() -> void:
	title = LocalizationData.tr_key("RATE_PICKER_TITLE")
	if btn_ok: btn_ok.text = LocalizationData.tr_key("BTN_OK")
	if btn_cancel: btn_cancel.text = LocalizationData.tr_key("BTN_CANCEL")

func open_for_track(track: SoundscapeData.TrackConfig, target_global_pos: Vector2 = Vector2.ZERO) -> void:
	if track == null: return
	current_track_id = track.id
	selected_counter = clampi(track.trigger.density_count, 1, MAX_COUNTER)
	selected_unit = track.trigger.get_unit_str()
	if not TIME_UNITS.has(selected_unit):
		selected_unit = "1m"

	_update_highlights()
	_update_preview()
	
	popup_centered()

	# Scroll counter to selected index
	if count_scroll and selected_counter > 3:
		var target_scroll: int = (selected_counter - 3) * 26
		count_scroll.scroll_vertical = target_scroll

func _select_counter(val: int) -> void:
	selected_counter = val
	_update_highlights()
	_update_preview()

func _select_unit(u: String) -> void:
	selected_unit = u
	_update_highlights()
	_update_preview()

func _update_preview() -> void:
	if preview_label:
		preview_label.text = "%dx / %s" % [selected_counter, selected_unit]

func _update_highlights() -> void:
	var pal: Dictionary = ThemeManager.get_palette()
	for i in range(_count_buttons.size()):
		var btn: Button = _count_buttons[i]
		var c_val: int = i + 1
		if c_val == selected_counter:
			btn.text = "%dx" % c_val
			btn.modulate = Color(1.3, 1.3, 1.0)
			btn.add_theme_color_override("font_color", pal["primary"])
		else:
			btn.text = "%d" % c_val
			btn.modulate = Color(0.7, 0.7, 0.7)
			btn.remove_theme_color_override("font_color")

	for i in range(_unit_buttons.size()):
		var btn: Button = _unit_buttons[i]
		var u_val: String = TIME_UNITS[i]
		if u_val == selected_unit:
			btn.modulate = Color(1.3, 1.3, 1.0)
			btn.add_theme_color_override("font_color", pal["primary"])
		else:
			btn.modulate = Color(0.7, 0.7, 0.7)
			btn.remove_theme_color_override("font_color")

func _on_ok_pressed() -> void:
	rate_applied.emit(current_track_id, selected_counter, selected_unit)
	hide()
