class_name AcousticEnvironmentManager
extends RefCounted

# Author: Adromir
# Reference: SpatialAudio3D (Godot Asset 3444 by Claude Hohl)
# Repository: https://github.com/adromir/3D-Soundscape-Studio

class AcousticBarrier extends RefCounted:
	var p1: Vector2 = Vector2.ZERO
	var p2: Vector2 = Vector2.ZERO
	var absorption: float = 0.5 # 0.0 (reflective) to 1.0 (dead)
	var transmission: float = 0.2 # 0.0 (solid stone wall) to 1.0 (transparent)
	var name: String = "Wall"

	func to_dict() -> Dictionary:
		return {
			"p1_x": p1.x, "p1_y": p1.y,
			"p2_x": p2.x, "p2_y": p2.y,
			"absorption": absorption,
			"transmission": transmission,
			"name": name
		}

	static func from_dict(d: Dictionary) -> AcousticBarrier:
		var b: AcousticBarrier = AcousticBarrier.new()
		b.p1 = Vector2(float(d.get("p1_x", 0.0)), float(d.get("p1_y", 0.0)))
		b.p2 = Vector2(float(d.get("p2_x", 0.0)), float(d.get("p2_y", 0.0)))
		b.absorption = float(d.get("absorption", 0.5))
		b.transmission = float(d.get("transmission", 0.2))
		b.name = str(d.get("name", "Wall"))
		return b

class AcousticZone extends RefCounted:
	var id: String = ""
	var name: String = "Cave Room"
	var bounds: Rect2 = Rect2(-5, -5, 10, 10)
	var reverb_room_size: float = 0.7
	var reverb_damping: float = 0.3
	var reverb_wetness: float = 0.4

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"x": bounds.position.x, "y": bounds.position.y,
			"w": bounds.size.x, "h": bounds.size.y,
			"reverb_room_size": reverb_room_size,
			"reverb_damping": reverb_damping,
			"reverb_wetness": reverb_wetness
		}

	static func from_dict(d: Dictionary) -> AcousticZone:
		var z: AcousticZone = AcousticZone.new()
		z.id = str(d.get("id", ""))
		z.name = str(d.get("name", "Acoustic Zone"))
		z.bounds = Rect2(float(d.get("x", -5.0)), float(d.get("y", -5.0)), float(d.get("w", 10.0)), float(d.get("h", 10.0)))
		z.reverb_room_size = float(d.get("reverb_room_size", 0.7))
		z.reverb_damping = float(d.get("reverb_damping", 0.3))
		z.reverb_wetness = float(d.get("reverb_wetness", 0.4))
		return z

var barriers: Array[AcousticBarrier] = []
var zones: Array[AcousticZone] = []

func clear() -> void:
	barriers.clear()
	zones.clear()

func add_barrier(p1: Vector2, p2: Vector2, absorption: float = 0.5, transmission: float = 0.2, b_name: String = "Wall") -> AcousticBarrier:
	var b: AcousticBarrier = AcousticBarrier.new()
	b.p1 = p1
	b.p2 = p2
	b.absorption = absorption
	b.transmission = transmission
	b.name = b_name
	barriers.append(b)
	return b

## Calculates occlusion transmission factor (1.0 = clear sight, 0.05 = heavily muffled)
func calculate_occlusion(sound_pos_2d: Vector2, listener_pos_2d: Vector2) -> float:
	if barriers.is_empty():
		return 1.0

	var total_transmission: float = 1.0
	for b in barriers:
		if _segments_intersect(sound_pos_2d, listener_pos_2d, b.p1, b.p2):
			total_transmission *= clampf(b.transmission, 0.05, 1.0)

	return clampf(total_transmission, 0.05, 1.0)

## Calculates cutoff frequency in Hz for lowpass filter based on occlusion
func calculate_lowpass_cutoff(occlusion_factor: float) -> float:
	# 1.0 -> 20000 Hz, 0.1 -> 800 Hz, 0.05 -> 400 Hz
	return clampf(20000.0 * pow(occlusion_factor, 1.5), 350.0, 20000.0)

## Gets the active acoustic zone properties for the listener
func get_active_zone_for_listener(listener_pos_2d: Vector2) -> AcousticZone:
	for z in zones:
		if z.bounds.has_point(listener_pos_2d):
			return z
	return null

## Fast 2D segment intersection
static func _segments_intersect(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> bool:
	var d_ab: Vector2 = b - a
	var d_cd: Vector2 = d - c
	var cross: float = d_ab.x * d_cd.y - d_ab.y * d_cd.x
	if absf(cross) < 0.00001:
		return false # Parallel

	var d_ac: Vector2 = c - a
	var t: float = (d_ac.x * d_cd.y - d_ac.y * d_cd.x) / cross
	var u: float = (d_ac.x * d_ab.y - d_ac.y * d_ab.x) / cross

	return (t >= 0.0 and t <= 1.0 and u >= 0.0 and u <= 1.0)
