class_name TracksWindow
extends Window

# Author: Adromir
# Repository: https://github.com/adromir

signal redock_requested()

@onready var btn_dock: Button = $Margin/VBox/TopHBox/BtnDock
@onready var slot: PanelContainer = $Margin/VBox/Slot

func _ready() -> void:
	title = "Audio Stems / Tracks"
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

func embed_content(control: Control) -> void:
	if slot and control:
		if control.get_parent():
			control.get_parent().remove_child(control)
		control.position = Vector2.ZERO
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.add_child(control)
