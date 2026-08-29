class_name RadarWindow
extends Window

# Author: Adromir
# Repository: https://github.com/adromir

signal redock_requested()

@onready var container: MarginContainer = $Margin
@onready var btn_dock: Button = $Margin/VBox/TopHBox/BtnDock
@onready var title_label: Label = $Margin/VBox/TopHBox/TitleLabel
@onready var canvas_slot: PanelContainer = $Margin/VBox/CanvasSlot

func _ready() -> void:
	title = "3D Spatial Radar Monitor"
	close_requested.connect(func():
		hide()
		redock_requested.emit()
	)
	if btn_dock:
		btn_dock.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_dock.pressed.connect(func():
			hide()
			redock_requested.emit()
		)

func embed_canvas(canvas: Control) -> void:
	if canvas_slot and canvas:
		if canvas.get_parent():
			canvas.get_parent().remove_child(canvas)
		canvas.position = Vector2.ZERO
		canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
		canvas_slot.add_child(canvas)
		canvas.queue_redraw()
