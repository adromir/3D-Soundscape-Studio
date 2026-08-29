class_name SoundscapeScheduler
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir

class RuntimeTrackState extends RefCounted:
	var track: SoundscapeData.TrackConfig
	var time_since_last_play: float = 0.0
	var current_cooldown_remaining: float = 0.0
	var next_trigger_delay: float = 0.0
	var is_playing: bool = false
	var stream_length: float = 5.0 # Estimated or queried

	func _init(t: SoundscapeData.TrackConfig) -> void:
		track = t
		_schedule_next(true)

	func _schedule_next(is_initial: bool = false) -> void:
		if track.trigger.mode == SoundscapeData.TriggerMode.FIXED_INTERVAL:
			var interval: float = maxf(track.trigger.fixed_interval_sec, track.trigger.cooldown_sec)
			next_trigger_delay = randf_range(0.5, interval) if is_initial else interval
		elif track.trigger.mode == SoundscapeData.TriggerMode.RANDOM_INTERVAL:
			var count: int = maxi(track.trigger.density_count, 1)
			var window_sec: float = maxf(track.trigger.density_window_sec, 1.0)
			var avg_interval: float = window_sec / float(count)
			var min_interval: float = maxf(avg_interval * 0.35, track.trigger.cooldown_sec)
			var max_interval: float = avg_interval * 1.65
			if is_initial:
				# First trigger fires earlier within the first slice of the window
				next_trigger_delay = randf_range(min_interval * 0.2, min_interval * 1.2)
			else:
				next_trigger_delay = randf_range(min_interval, max_interval)
		else:
			next_trigger_delay = 0.0

	func update(delta: float) -> bool:
		# Returns true if track should trigger play
		if track.muted:
			return false

		if track.trigger.mode == SoundscapeData.TriggerMode.CONTINUOUS_LOOP:
			return false # Handled natively by stream looping

		if current_cooldown_remaining > 0.0:
			current_cooldown_remaining -= delta
			return false

		time_since_last_play += delta
		if time_since_last_play >= next_trigger_delay:
			time_since_last_play = 0.0
			current_cooldown_remaining = maxf(track.trigger.cooldown_sec, 0.5)
			_schedule_next(false)
			return true

		return false

## Deterministic offline timeline generation for FFmpeg export
static func generate_offline_timeline(project: SoundscapeData.SoundscapeProject, duration_sec: float, rng_seed: int = 12345) -> Dictionary:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = rng_seed

	var track_timelines: Dictionary = {} # track_id -> Array[Dictionary] (events)

	for track in project.tracks:
		var events: Array[Dictionary] = []
		if track.muted:
			track_timelines[track.id] = events
			continue

		var current_azimuth: float = track.azimuth
		var current_elevation: float = track.elevation
		var current_distance: float = track.distance

		if track.trigger.mode == SoundscapeData.TriggerMode.CONTINUOUS_LOOP:
			events.append({
				"start_time": 0.0,
				"duration": duration_sec,
				"is_loop": true,
				"azimuth": current_azimuth,
				"elevation": current_elevation,
				"distance": current_distance
			})
		elif track.trigger.mode == SoundscapeData.TriggerMode.FIXED_INTERVAL:
			var t: float = 0.0
			var interval: float = maxf(track.trigger.fixed_interval_sec, track.trigger.cooldown_sec)
			while t < duration_sec:
				events.append({
					"start_time": t,
					"duration": -1.0, # Single play
					"is_loop": false,
					"azimuth": current_azimuth,
					"elevation": current_elevation,
					"distance": current_distance
				})
				t += interval
		elif track.trigger.mode == SoundscapeData.TriggerMode.RANDOM_INTERVAL:
			var t: float = rng.randf_range(0.0, 2.0)
			var count: int = maxi(track.trigger.density_count, 1)
			var window_sec: float = maxf(track.trigger.density_window_sec, 1.0)
			var avg_interval: float = window_sec / float(count)
			var min_interval: float = maxf(avg_interval * 0.4, track.trigger.cooldown_sec)
			var max_interval: float = avg_interval * 1.6

			while t < duration_sec:
				# Check for random walk / jump per trigger
				if track.movement.pattern == SoundscapeData.MovementPattern.RANDOM_WALK and track.movement.timing == SoundscapeData.MovementTiming.JUMP_PER_TRIGGER:
					var delta_azimuth: float = rng.randf_range(-45.0, 45.0)
					current_azimuth = clampf(current_azimuth + delta_azimuth, track.movement.min_azimuth, track.movement.max_azimuth)

				events.append({
					"start_time": t,
					"duration": -1.0,
					"is_loop": false,
					"azimuth": current_azimuth,
					"elevation": current_elevation,
					"distance": current_distance
				})
				var next_gap: float = rng.randf_range(min_interval, max_interval)
				t += next_gap

		track_timelines[track.id] = events

	return track_timelines
