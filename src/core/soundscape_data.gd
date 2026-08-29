class_name SoundscapeData
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir

enum MovementPattern {
	NONE,
	PING_PONG_LR,
	ONE_WAY_LR,
	PING_PONG_FB,
	ONE_WAY_FB,
	RANDOM_WALK
}

enum MovementTiming {
	CONTINUOUS_IN_FLIGHT,
	JUMP_PER_TRIGGER
}

enum ChannelRoutingMode {
	POINT_3D,
	OMNIPRESENT,
	MULTI_CHANNEL
}

enum TriggerMode {
	CONTINUOUS_LOOP,
	FIXED_INTERVAL,
	RANDOM_INTERVAL
}

class MovementConfig extends RefCounted:
	var pattern: MovementPattern = MovementPattern.NONE
	var timing: MovementTiming = MovementTiming.CONTINUOUS_IN_FLIGHT
	var speed: float = 1.0
	var min_azimuth: float = -90.0
	var max_azimuth: float = 90.0
	var min_distance: float = 1.0
	var max_distance: float = 10.0
	var min_elevation: float = 0.0
	var max_elevation: float = 0.0
	var current_azimuth: float = 0.0
	var current_elevation: float = 0.0
	var current_distance: float = 2.0
	var direction: float = 1.0 # 1.0 forward, -1.0 backward for ping-pong
	var wander_heading: float = 0.0
	var wander_timer: float = 0.0
	var wander_target_heading: float = 0.0

	func to_dict() -> Dictionary:
		return {
			"pattern": pattern,
			"timing": timing,
			"speed": speed,
			"min_azimuth": min_azimuth,
			"max_azimuth": max_azimuth,
			"min_distance": min_distance,
			"max_distance": max_distance,
			"min_elevation": min_elevation,
			"max_elevation": max_elevation,
			"current_azimuth": current_azimuth,
			"current_elevation": current_elevation,
			"current_distance": current_distance,
			"direction": direction
		}

	static func from_dict(dict: Dictionary) -> MovementConfig:
		var config: MovementConfig = MovementConfig.new()
		if dict.is_empty():
			return config
		config.pattern = dict.get("pattern", MovementPattern.NONE) as MovementPattern
		config.timing = dict.get("timing", MovementTiming.CONTINUOUS_IN_FLIGHT) as MovementTiming
		config.speed = float(dict.get("speed", 1.0))
		config.min_azimuth = float(dict.get("min_azimuth", -90.0))
		config.max_azimuth = float(dict.get("max_azimuth", 90.0))
		config.min_distance = float(dict.get("min_distance", 1.0))
		config.max_distance = float(dict.get("max_distance", 10.0))
		config.min_elevation = float(dict.get("min_elevation", 0.0))
		config.max_elevation = float(dict.get("max_elevation", 0.0))
		config.current_azimuth = float(dict.get("current_azimuth", 0.0))
		config.current_elevation = float(dict.get("current_elevation", 0.0))
		config.current_distance = float(dict.get("current_distance", 2.0))
		config.direction = float(dict.get("direction", 1.0))
		return config

class TriggerConfig extends RefCounted:
	var mode: TriggerMode = TriggerMode.CONTINUOUS_LOOP
	var fixed_interval_sec: float = 5.0
	var density_count: int = 1
	var density_window_sec: float = 60.0 # 1 minute default (1x / 1m)
	var cooldown_sec: float = 2.0 # Minimum gap between plays (Blockwert)

	func get_rate_label() -> String:
		if is_equal_approx(density_window_sec, 60.0):
			return "%dx /1m" % density_count
		elif is_equal_approx(density_window_sec, 300.0):
			return "%dx /5m" % density_count
		elif is_equal_approx(density_window_sec, 600.0):
			return "%dx /10m" % density_count
		elif is_equal_approx(density_window_sec, 900.0):
			return "%dx /15m" % density_count
		elif is_equal_approx(density_window_sec, 1800.0):
			return "%dx /30m" % density_count
		elif is_equal_approx(density_window_sec, 3600.0):
			return "%dx /1h" % density_count
		elif density_window_sec >= 3600.0:
			var hrs: float = density_window_sec / 3600.0
			return "%dx /%.1fh" % [density_count, hrs] if not is_equal_approx(hrs, roundf(hrs)) else "%dx /%dh" % [density_count, int(hrs)]
		elif density_window_sec >= 60.0:
			var mins: float = density_window_sec / 60.0
			return "%dx /%.1fm" % [density_count, mins] if not is_equal_approx(mins, roundf(mins)) else "%dx /%dm" % [density_count, int(mins)]
		else:
			return "%dx /%ds" % [density_count, int(density_window_sec)]

	func get_unit_str() -> String:
		if is_equal_approx(density_window_sec, 60.0): return "1m"
		elif is_equal_approx(density_window_sec, 300.0): return "5m"
		elif is_equal_approx(density_window_sec, 600.0): return "10m"
		elif is_equal_approx(density_window_sec, 900.0): return "15m"
		elif is_equal_approx(density_window_sec, 1800.0): return "30m"
		elif is_equal_approx(density_window_sec, 3600.0): return "1h"
		elif is_equal_approx(density_window_sec, 7200.0): return "2h"
		elif density_window_sec >= 3600.0:
			var hrs: int = int(round(density_window_sec / 3600.0))
			return "%dh" % hrs
		elif density_window_sec >= 60.0:
			var mins: int = int(round(density_window_sec / 60.0))
			return "%dm" % mins
		else:
			return "%ds" % int(density_window_sec)

	func set_from_rate_unit(counter: int, unit_str: String) -> void:
		density_count = maxi(counter, 1)
		unit_str = unit_str.strip_edges().to_lower()
		if unit_str == "1m":
			density_window_sec = 60.0
		elif unit_str == "5m":
			density_window_sec = 300.0
		elif unit_str == "10m":
			density_window_sec = 600.0
		elif unit_str == "15m":
			density_window_sec = 900.0
		elif unit_str == "30m":
			density_window_sec = 1800.0
		elif unit_str == "1h":
			density_window_sec = 3600.0
		elif unit_str.ends_with("h"):
			var h_val: float = unit_str.trim_suffix("h").to_float()
			density_window_sec = maxf(h_val * 3600.0, 10.0)
		elif unit_str.ends_with("m"):
			var m_val: float = unit_str.trim_suffix("m").to_float()
			density_window_sec = maxf(m_val * 60.0, 5.0)
		elif unit_str.ends_with("s"):
			density_window_sec = maxf(unit_str.trim_suffix("s").to_float(), 1.0)
		elif unit_str.is_valid_float():
			density_window_sec = maxf(unit_str.to_float(), 1.0)
		else:
			density_window_sec = 60.0

	func apply_preset(count: int, window_sec: float, cooldown: float = 2.0) -> void:
		mode = TriggerMode.RANDOM_INTERVAL
		density_count = maxi(count, 1)
		density_window_sec = maxf(window_sec, 1.0)
		cooldown_sec = maxf(cooldown, 0.5)

	func to_dict() -> Dictionary:
		return {
			"mode": mode,
			"fixed_interval_sec": fixed_interval_sec,
			"density_count": density_count,
			"density_window_sec": density_window_sec,
			"cooldown_sec": cooldown_sec
		}

	static func from_dict(dict: Dictionary) -> TriggerConfig:
		var config: TriggerConfig = TriggerConfig.new()
		if dict.is_empty():
			return config
		config.mode = dict.get("mode", TriggerMode.CONTINUOUS_LOOP) as TriggerMode
		config.fixed_interval_sec = float(dict.get("fixed_interval_sec", 5.0))
		config.density_count = int(dict.get("density_count", 1))
		config.density_window_sec = float(dict.get("density_window_sec", 60.0))
		config.cooldown_sec = float(dict.get("cooldown_sec", 2.0))
		return config

class TrackConfig extends RefCounted:
	var id: String = ""
	var name: String = "Track"
	var file_path: String = ""
	var volume: float = 1.0
	var muted: bool = false
	var solo: bool = false
	var color_hex: String = "#00e5ff" # Default Neon Cyan
	var icon_name: String = "volume" # volume, fire, water, birds, wind, rain, bell, steps, music, fx, voice
	var azimuth: float = 0.0 # -180 to 180 degrees
	var elevation: float = 0.0 # -90 to 90 degrees
	var distance: float = 2.0 # Distance in meters/units
	var spread_radius: float = 0.0 # Width/spread of sound body in degrees
	var channel_mode: ChannelRoutingMode = ChannelRoutingMode.POINT_3D
	var target_channels: Array[String] = [] # e.g. ["FL", "FR"] if MULTI_CHANNEL
	var impulse_response_path: String = ""
	var crossfade: bool = false # Seamless loop crossfade
	var movement: MovementConfig = MovementConfig.new()
	var trigger: TriggerConfig = TriggerConfig.new()
	var initial_snapshot: Dictionary = {}

	func capture_initial_snapshot() -> void:
		initial_snapshot = to_dict()

	func reset_to_initial() -> void:
		if not initial_snapshot.is_empty():
			var restored: TrackConfig = TrackConfig.from_dict(initial_snapshot)
			volume = restored.volume
			muted = restored.muted
			solo = restored.solo
			color_hex = restored.color_hex
			icon_name = restored.icon_name
			azimuth = restored.azimuth
			elevation = restored.elevation
			distance = restored.distance
			spread_radius = restored.spread_radius
			channel_mode = restored.channel_mode
			target_channels = restored.target_channels.duplicate()
			crossfade = restored.crossfade
			movement = MovementConfig.from_dict(initial_snapshot.get("movement", {}))
			trigger = TriggerConfig.from_dict(initial_snapshot.get("trigger", {}))
		else:
			# Factory default baseline
			volume = 1.0
			muted = false
			solo = false
			azimuth = 0.0
			elevation = 0.0
			distance = 2.0
			spread_radius = 0.0
			channel_mode = ChannelRoutingMode.POINT_3D
			target_channels = []
			crossfade = false
			movement = MovementConfig.new()
			trigger = TriggerConfig.new()

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"file_path": file_path,
			"volume": volume,
			"muted": muted,
			"solo": solo,
			"color_hex": color_hex,
			"icon_name": icon_name,
			"azimuth": azimuth,
			"elevation": elevation,
			"distance": distance,
			"spread_radius": spread_radius,
			"channel_mode": channel_mode,
			"target_channels": target_channels,
			"impulse_response_path": impulse_response_path,
			"crossfade": crossfade,
			"movement": movement.to_dict(),
			"trigger": trigger.to_dict()
		}

	static func from_dict(dict: Dictionary) -> TrackConfig:
		var track: TrackConfig = TrackConfig.new()
		track.id = dict.get("id", "")
		track.name = dict.get("name", "Track")
		track.file_path = dict.get("file_path", "")
		track.volume = float(dict.get("volume", 1.0))
		track.muted = bool(dict.get("muted", false))
		track.solo = bool(dict.get("solo", false))
		track.color_hex = dict.get("color_hex", "#00e5ff")
		track.icon_name = dict.get("icon_name", "volume")
		track.azimuth = float(dict.get("azimuth", 0.0))
		track.elevation = float(dict.get("elevation", 0.0))
		track.distance = float(dict.get("distance", 2.0))
		track.spread_radius = float(dict.get("spread_radius", 0.0))
		track.channel_mode = dict.get("channel_mode", ChannelRoutingMode.POINT_3D) as ChannelRoutingMode
		track.crossfade = bool(dict.get("crossfade", false))
		
		var raw_channels: Array = dict.get("target_channels", [])
		track.target_channels = []
		for ch in raw_channels:
			track.target_channels.append(str(ch))
			
		track.impulse_response_path = dict.get("impulse_response_path", "")
		track.movement = MovementConfig.from_dict(dict.get("movement", {}))
		track.trigger = TriggerConfig.from_dict(dict.get("trigger", {}))
		track.capture_initial_snapshot()
		return track

class ListenerPathConfig extends RefCounted:
	var enabled: bool = false
	var points: Array[Vector3] = []
	var speed: float = 1.0
	var loop: bool = false

	func to_dict() -> Dictionary:
		var pts_array: Array = []
		for p in points:
			pts_array.append({"x": p.x, "y": p.y, "z": p.z})
		return {
			"enabled": enabled,
			"points": pts_array,
			"speed": speed,
			"loop": loop
		}

	static func from_dict(dict: Dictionary) -> ListenerPathConfig:
		var config: ListenerPathConfig = ListenerPathConfig.new()
		config.enabled = bool(dict.get("enabled", false))
		config.speed = float(dict.get("speed", 1.0))
		config.loop = bool(dict.get("loop", false))
		config.points = []
		var pts_array: Array = dict.get("points", [])
		for pt in pts_array:
			if pt is Dictionary:
				config.points.append(Vector3(float(pt.get("x", 0.0)), float(pt.get("y", 0.0)), float(pt.get("z", 0.0))))
		return config

class SoundscapeProject extends RefCounted:
	var source_path: String = ""
	var title: String = "Untitled Soundscape"
	var description: String = ""
	var author: String = "Adromir"
	var cover_image_path: String = ""
	var soundspace_radius: float = 10.0
	var target_duration_sec: int = 300 # 5 minutes default
	var speaker_layout: SpeakerLayouts.LayoutType = SpeakerLayouts.LayoutType.BINAURAL_SOFA
	var sofa_path: String = ""
	var master_volume: float = 1.0
	var listener_path: ListenerPathConfig = ListenerPathConfig.new()
	var tracks: Array[TrackConfig] = []

	func to_dict() -> Dictionary:
		var tracks_data: Array = []
		for track in tracks:
			tracks_data.append(track.to_dict())

		return {
			"version": 1,
			"title": title,
			"description": description,
			"author": author,
			"cover_image_path": cover_image_path,
			"soundspace_radius": soundspace_radius,
			"target_duration_sec": target_duration_sec,
			"speaker_layout": speaker_layout,
			"sofa_path": sofa_path,
			"master_volume": master_volume,
			"listener_path": listener_path.to_dict(),
			"tracks": tracks_data
		}

	static func from_dict(dict: Dictionary) -> SoundscapeProject:
		var project: SoundscapeProject = SoundscapeProject.new()
		project.title = dict.get("title", "Untitled Soundscape")
		project.description = dict.get("description", "")
		project.author = dict.get("author", "Adromir")
		project.cover_image_path = dict.get("cover_image_path", "")
		project.soundspace_radius = float(dict.get("soundspace_radius", 10.0))
		project.target_duration_sec = int(dict.get("target_duration_sec", 300))
		project.speaker_layout = dict.get("speaker_layout", SpeakerLayouts.LayoutType.BINAURAL_SOFA) as SpeakerLayouts.LayoutType
		project.sofa_path = dict.get("sofa_path", "")
		project.master_volume = float(dict.get("master_volume", 1.0))
		project.listener_path = ListenerPathConfig.from_dict(dict.get("listener_path", {}))

		project.tracks = []
		var tracks_data: Array = dict.get("tracks", [])
		for td in tracks_data:
			if td is Dictionary:
				project.tracks.append(TrackConfig.from_dict(td))

		return project

	func save_to_file(path: String) -> bool:
		var global_path: String = ProjectSettings.globalize_path(path)
		var file: FileAccess = FileAccess.open(global_path, FileAccess.WRITE)
		if file == null:
			printerr("Failed to save project to: ", path)
			return false
		var json_string: String = JSON.stringify(to_dict(), "\t")
		file.store_string(json_string)
		file.close()
		source_path = path
		return true

	static func load_from_file(path: String) -> SoundscapeProject:
		var global_path: String = ProjectSettings.globalize_path(path)
		if not FileAccess.file_exists(global_path):
			printerr("Project file not found: ", path)
			return null
		var file: FileAccess = FileAccess.open(global_path, FileAccess.READ)
		if file == null:
			printerr("Failed to open project file: ", path)
			return null
		var content: String = file.get_as_text()
		file.close()

		var test_json_conv: JSON = JSON.new()
		var parse_err: Error = test_json_conv.parse(content)
		if parse_err != OK:
			printerr("JSON parse error on project: ", path, " error: ", parse_err)
			return null

		var dict: Dictionary = test_json_conv.get_data() as Dictionary
		var project: SoundscapeProject = SoundscapeProject.from_dict(dict)
		project.source_path = path
		return project
