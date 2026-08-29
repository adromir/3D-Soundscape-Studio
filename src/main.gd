extends Node

# Author: Adromir
# Repository: https://github.com/adromir

@onready var main_view: MainView = $MainView

func _ready() -> void:
	DisplayServer.window_set_title("3D Soundscape Studio")
