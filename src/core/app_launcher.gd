class_name AppLauncher
extends Node

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

func _ready() -> void:
	var cmdline_args: PackedStringArray = OS.get_cmdline_args()
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	var exe_name: String = OS.get_executable_path().get_file().to_lower()

	var is_player: bool = false

	# 1. Feature tags (set in export presets with custom_features="player" or on iOS/Android)
	if OS.has_feature("player") or OS.has_feature("mobile"):
		is_player = true

	# 2. Executable filename detection (e.g. 3D-Ambient-Player.exe, 3d-ambient-player)
	if exe_name.contains("player") or exe_name.contains("ambient"):
		is_player = true

	# 3. CLI arguments (--player, -p, --app=player)
	for arg in cmdline_args + user_args:
		var lower: String = arg.to_lower()
		if lower == "--player" or lower == "-p" or lower == "--app=player":
			is_player = true
			break
		elif lower == "--studio" or lower == "-s" or lower == "--app=studio":
			is_player = false
			break

	if is_player:
		get_tree().change_scene_to_file.call_deferred("res://src/player/player_view.tscn")
	else:
		get_tree().change_scene_to_file.call_deferred("res://src/ui/main_view.tscn")
