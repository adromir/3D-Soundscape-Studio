class_name SpatialEngine
extends Node3D

# Author: Adromir
# Repository: https://github.com/adromir

signal track_triggered(track_id: String)
signal track_position_updated(track_id: String, azimuth: float, elevation: float, distance: float)
signal listener_position_updated(pos: Vector3, t: float)
signal playback_state_changed(is_playing: bool)



var _project: SoundscapeData.SoundscapeProject = null
var _audio_players: Dictionary = {} # track_id -> AudioStreamPlayer3D or AudioStreamPlayer
var _schedulers: Dictionary = {} # track_id -> SoundscapeScheduler.RuntimeTrackState
var _streams: Dictionary = {} # track_id -> AudioStream
var _is_playing: bool = false
var is_playing: bool:
	get: return _is_playing
var speaker_layout: SpeakerLayouts.LayoutType = SpeakerLayouts.LayoutType.BINAURAL_SOFA
var acoustic_env: AcousticEnvironmentManager = AcousticEnvironmentManager.new()

var _audio_viewport: SubViewport = null
var _camera_3d: Camera3D = null
var _listener_3d: AudioListener3D = null

func _ready() -> void:
	if get_viewport():
		get_viewport().audio_listener_enable_3d = true
	_ensure_audio_environment()

func _ensure_audio_environment() -> void:
	if _audio_viewport == null:
		_audio_viewport = SubViewport.new()
		_audio_viewport.name = "SpatialAudioViewport"
		_audio_viewport.audio_listener_enable_3d = true
		_audio_viewport.gui_disable_input = true
		_audio_viewport.size = Vector2i(2, 2)
		add_child(_audio_viewport)

		_camera_3d = Camera3D.new()
		_camera_3d.name = "AudioCamera3D"
		_camera_3d.current = true
		_audio_viewport.add_child(_camera_3d)

		_listener_3d = AudioListener3D.new()
		_listener_3d.name = "AudioListener3D"
		_audio_viewport.add_child(_listener_3d)
		_listener_3d.make_current()

func load_project(project: SoundscapeData.SoundscapeProject) -> void:
	stop_all()
	_cleanup_players()
	_project = project

	acoustic_env.clear()
	if _project:
		for b_dict in _project.barriers:
			acoustic_env.barriers.append(AcousticEnvironmentManager.AcousticBarrier.from_dict(b_dict))
		for z_dict in _project.zones:
			acoustic_env.zones.append(AcousticEnvironmentManager.AcousticZone.from_dict(z_dict))

		for track in _project.tracks:
			_setup_track_player(track)

func _cleanup_players() -> void:
	for id in _audio_players.keys():
		var p: Node = _audio_players[id]
		p.queue_free()
	_audio_players.clear()
	_schedulers.clear()
	_streams.clear()

func _set_stream_loop(stream: AudioStream, is_loop: bool) -> void:
	if stream is AudioStreamMP3:
		stream.loop = is_loop
	elif stream is AudioStreamOggVorbis:
		stream.loop = is_loop
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if is_loop else AudioStreamWAV.LOOP_DISABLED

func _setup_track_player(track: SoundscapeData.TrackConfig) -> void:
	var stream: AudioStream = AudioImporter.load_audio_stream(track.file_path)
	if stream == null:
		# Fallback: synthesize procedural audio stream so tracks ALWAYS have rich preview sound!
		stream = _generate_synthetic_stream(track.icon_name, track.name, track.channel_mode == SoundscapeData.ChannelRoutingMode.OMNIPRESENT)
	if stream == null:
		return

	_set_stream_loop(stream, track.trigger.mode == SoundscapeData.TriggerMode.CONTINUOUS_LOOP)
	_streams[track.id] = stream
	_schedulers[track.id] = SoundscapeScheduler.RuntimeTrackState.new(track)

	var master_vol: float = _project.master_volume if _project else 1.0
	var effective_vol: float = track.volume if not track.muted else 0.0
	var initial_db: float = linear_to_db(effective_vol * master_vol) if effective_vol > 0.0001 else -80.0

	if track.channel_mode == SoundscapeData.ChannelRoutingMode.OMNIPRESENT:
		var p2d: AudioStreamPlayer = AudioStreamPlayer.new()
		p2d.stream = stream
		p2d.bus = "Master"
		p2d.volume_db = initial_db
		add_child(p2d)
		_audio_players[track.id] = p2d
	else:
		_ensure_audio_environment()
		var p3d: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		p3d.stream = stream
		p3d.bus = "Master"
		p3d.unit_size = 12.0
		p3d.max_distance = 300.0
		p3d.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		p3d.panning_strength = 1.0
		p3d.volume_db = initial_db
		_audio_viewport.add_child(p3d)
		_audio_players[track.id] = p3d
		_update_player_3d_position(track, p3d)

func _generate_synthetic_stream(icon_name: String, track_name: String, is_stereo: bool = false) -> AudioStreamWAV:
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	var sample_rate: int = 22050
	var duration: float = 1.5
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	var channels: int = 2 if is_stereo else 1
	data.resize(num_samples * 2 * channels)

	var icon_lower: String = (icon_name + " " + track_name).to_lower()
	var base_freq: float = 220.0
	var is_noise: bool = false
	var noise_filter: float = 0.5

	if icon_lower.contains("rain") or icon_lower.contains("storm"):
		is_noise = true
		noise_filter = 0.25
	elif icon_lower.contains("wind") or icon_lower.contains("breeze"):
		is_noise = true
		base_freq = 80.0
		noise_filter = 0.15
	elif icon_lower.contains("fire") or icon_lower.contains("camp"):
		is_noise = true
		base_freq = 110.0
		noise_filter = 0.35
	elif icon_lower.contains("bird") or icon_lower.contains("owl"):
		base_freq = 880.0
	elif icon_lower.contains("water") or icon_lower.contains("stream"):
		is_noise = true
		noise_filter = 0.30
	else:
		base_freq = 165.0

	var last_val: float = 0.0
	var phase: float = 0.0
	var byte_idx: int = 0

	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var sample_f: float = 0.0

		if is_noise:
			var raw_n: float = randf_range(-1.0, 1.0)
			last_val = lerpf(last_val, raw_n, noise_filter)
			var lfo: float = 0.7 + 0.3 * sin(t * TAU * 1.5)
			sample_f = last_val * lfo * 0.35
			if icon_lower.contains("rain") and randf() < 0.003:
				sample_f += randf_range(0.2, 0.5)
			elif icon_lower.contains("fire") and randf() < 0.002:
				sample_f += randf_range(0.3, 0.6)
		else:
			if icon_lower.contains("bird") or icon_lower.contains("owl"):
				var mod_pitch: float = base_freq + sin(t * TAU * 8.0) * 150.0
				phase += mod_pitch / float(sample_rate)
				var env: float = 0.5 + 0.5 * sin(t * TAU * 3.0)
				sample_f = sin(phase * TAU) * env * 0.25
			else:
				phase += base_freq / float(sample_rate)
				var harmonic: float = sin(phase * TAU) * 0.5 + sin(phase * 1.5 * TAU) * 0.3 + sin(phase * 2.0 * TAU) * 0.2
				sample_f = harmonic * 0.3

		# Window boundaries for click-free seamless looping
		var fade_samples: int = int(sample_rate * 0.05)
		if i < fade_samples:
			sample_f *= float(i) / float(fade_samples)
		elif i > num_samples - fade_samples:
			sample_f *= float(num_samples - i) / float(fade_samples)

		var sample_i16: int = clampi(int(sample_f * 32767.0), -32768, 32767)
		data.encode_s16(byte_idx, sample_i16)
		byte_idx += 2

		if is_stereo:
			data.encode_s16(byte_idx, sample_i16)
			byte_idx += 2

	wav.data = data
	wav.mix_rate = sample_rate
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = is_stereo
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = num_samples
	return wav

func reload_track_stream(track: SoundscapeData.TrackConfig) -> void:
	if track == null: return
	if _audio_players.has(track.id):
		var old_p: Node = _audio_players[track.id]
		old_p.queue_free()
		_audio_players.erase(track.id)
	_setup_track_player(track)
	if _is_playing and not track.muted and track.trigger.mode == SoundscapeData.TriggerMode.CONTINUOUS_LOOP:
		_play_track_stream(track.id, true)

func play_all() -> void:
	_is_playing = true
	for track in _project.tracks:
		if track.muted:
			continue
		if track.trigger.mode == SoundscapeData.TriggerMode.CONTINUOUS_LOOP:
			_play_track_stream(track.id, true)
		else:
			# Prime scheduler for natural randomized lead-in
			if _schedulers.has(track.id):
				_schedulers[track.id]._schedule_next(true)
	playback_state_changed.emit(_is_playing)

func stop_all() -> void:
	_is_playing = false
	for id in _audio_players.keys():
		var player: Node = _audio_players[id]
		if player is AudioStreamPlayer3D:
			player.stop()
		elif player is AudioStreamPlayer:
			player.stop()
	playback_state_changed.emit(_is_playing)

func pause_all() -> void:
	_is_playing = false
	for id in _audio_players.keys():
		var player: Node = _audio_players[id]
		if player is AudioStreamPlayer3D:
			player.stream_paused = true
		elif player is AudioStreamPlayer:
			player.stream_paused = true
	playback_state_changed.emit(_is_playing)

func resume_all() -> void:
	_is_playing = true
	for id in _audio_players.keys():
		var player: Node = _audio_players[id]
		if player is AudioStreamPlayer3D:
			player.stream_paused = false
		elif player is AudioStreamPlayer:
			player.stream_paused = false
	playback_state_changed.emit(_is_playing)

func _play_track_stream(track_id: String, _loop: bool) -> void:
	if not _audio_players.has(track_id):
		return
	var player: Node = _audio_players[track_id]
	var track: SoundscapeData.TrackConfig = _get_track_by_id(track_id)
	if track == null or track.muted:
		return

	# Handle jump-per-trigger movement
	if track.movement.pattern != SoundscapeData.MovementPattern.NONE and track.movement.timing == SoundscapeData.MovementTiming.JUMP_PER_TRIGGER:
		_apply_jump_movement(track)

	var master_vol: float = _project.master_volume if _project else 1.0
	var effective_vol: float = track.volume if not track.muted else 0.0
	var db: float = linear_to_db(effective_vol * master_vol) if effective_vol > 0.0001 else -80.0

	if player is AudioStreamPlayer3D:
		_update_player_3d_position(track, player)
		player.volume_db = db
		player.play()
	elif player is AudioStreamPlayer:
		player.volume_db = db
		player.play()

	track_triggered.emit(track_id)

func _process(delta: float) -> void:
	if not _is_playing or _project == null:
		return

	# Update listener movement if enabled
	_update_listener_path(delta)

	for track in _project.tracks:
		if track.muted:
			continue

		# Update movement if in-flight
		if track.movement.pattern != SoundscapeData.MovementPattern.NONE and track.movement.timing == SoundscapeData.MovementTiming.CONTINUOUS_IN_FLIGHT:
			_update_inflight_movement(track, delta)
			if _audio_players.has(track.id) and _audio_players[track.id] is AudioStreamPlayer3D:
				_update_player_3d_position(track, _audio_players[track.id])

		# Update trigger scheduler
		if _schedulers.has(track.id):
			var scheduler: SoundscapeScheduler.RuntimeTrackState = _schedulers[track.id]
			if scheduler.update(delta):
				_play_track_stream(track.id, false)

func _update_inflight_movement(track: SoundscapeData.TrackConfig, delta: float) -> void:
	var mov: SoundscapeData.MovementConfig = track.movement
	var speed_deg_sec: float = mov.speed * 20.0 # 20 degrees/sec baseline

	match mov.pattern:
		SoundscapeData.MovementPattern.PING_PONG_LR:
			track.azimuth += mov.direction * speed_deg_sec * delta
			if track.azimuth >= mov.max_azimuth:
				track.azimuth = mov.max_azimuth
				mov.direction = -1.0
			elif track.azimuth <= mov.min_azimuth:
				track.azimuth = mov.min_azimuth
				mov.direction = 1.0

		SoundscapeData.MovementPattern.ONE_WAY_LR:
			track.azimuth += speed_deg_sec * delta
			if track.azimuth > mov.max_azimuth:
				track.azimuth = mov.min_azimuth

		SoundscapeData.MovementPattern.ONE_WAY_RL:
			track.azimuth -= speed_deg_sec * delta
			if track.azimuth < mov.min_azimuth:
				track.azimuth = mov.max_azimuth

		SoundscapeData.MovementPattern.PING_PONG_FB:
			track.distance += mov.direction * (mov.speed * 1.5) * delta
			if track.distance >= mov.max_distance:
				track.distance = mov.max_distance
				mov.direction = -1.0
			elif track.distance <= mov.min_distance:
				track.distance = mov.min_distance
				mov.direction = 1.0

		SoundscapeData.MovementPattern.ONE_WAY_FB:
			track.distance -= (mov.speed * 1.5) * delta
			if track.distance < mov.min_distance:
				track.distance = mov.max_distance

		SoundscapeData.MovementPattern.ONE_WAY_BF:
			track.distance += (mov.speed * 1.5) * delta
			if track.distance > mov.max_distance:
				track.distance = mov.min_distance

		SoundscapeData.MovementPattern.ORBIT_CW:
			track.azimuth += speed_deg_sec * delta
			track.azimuth = wrapf(track.azimuth, -180.0, 180.0)

		SoundscapeData.MovementPattern.ORBIT_CCW:
			track.azimuth -= speed_deg_sec * delta
			track.azimuth = wrapf(track.azimuth, -180.0, 180.0)

		SoundscapeData.MovementPattern.SPIRAL_IN:
			track.azimuth += speed_deg_sec * delta
			track.azimuth = wrapf(track.azimuth, -180.0, 180.0)
			track.distance -= (mov.speed * 0.8) * delta
			if track.distance <= mov.min_distance:
				track.distance = mov.max_distance

		SoundscapeData.MovementPattern.SPIRAL_OUT:
			track.azimuth += speed_deg_sec * delta
			track.azimuth = wrapf(track.azimuth, -180.0, 180.0)
			track.distance += (mov.speed * 0.8) * delta
			if track.distance >= mov.max_distance:
				track.distance = mov.min_distance

		SoundscapeData.MovementPattern.FIGURE_EIGHT:
			mov.wander_timer += delta * (mov.speed * 0.8)
			var t: float = mov.wander_timer
			var a: float = maxf(mov.max_distance * 0.85, 2.0)
			var denom: float = 1.0 + sin(t) * sin(t)
			var fx: float = (a * cos(t)) / denom
			var fz: float = (a * sin(t) * cos(t)) / denom
			var dist: float = maxf(sqrt(fx * fx + fz * fz), mov.min_distance)
			track.distance = dist
			track.azimuth = rad_to_deg(atan2(fx, -fz))

		SoundscapeData.MovementPattern.RANDOM_WALK:
			# Smooth steering wander with persistent velocity across the soundspace
			mov.wander_timer -= delta
			if mov.wander_timer <= 0.0:
				mov.wander_target_heading = randf_range(-PI, PI)
				mov.wander_timer = randf_range(1.5, 3.5)

			# Smoothly rotate wander heading toward target
			mov.wander_heading = rotate_toward(mov.wander_heading, mov.wander_target_heading, delta * 2.0)

			# Convert current spherical coordinates to Cartesian (x, z)
			var az_rad: float = deg_to_rad(track.azimuth)
			var cur_x: float = track.distance * sin(az_rad)
			var cur_z: float = -track.distance * cos(az_rad)

			# Move along wander heading with velocity (speed in m/s)
			var vel_ms: float = maxf(mov.speed, 0.1) * 2.0
			var vx: float = cos(mov.wander_heading) * vel_ms
			var vz: float = sin(mov.wander_heading) * vel_ms

			var next_x: float = cur_x + vx * delta
			var next_z: float = cur_z + vz * delta

			var next_dist: float = sqrt(next_x * next_x + next_z * next_z)

			# Soft bounce if exceeding boundary
			if next_dist > mov.max_distance:
				# Steer back toward origin
				mov.wander_target_heading = atan2(-cur_z, -cur_x)
				mov.wander_heading = mov.wander_target_heading
				next_dist = mov.max_distance
				next_x = (next_x / (next_dist + 0.001)) * mov.max_distance
				next_z = (next_z / (next_dist + 0.001)) * mov.max_distance
			elif next_dist < mov.min_distance:
				next_dist = mov.min_distance

			# Convert Cartesian back to spherical
			track.distance = next_dist
			track.azimuth = rad_to_deg(atan2(next_x, -next_z))

	mov.current_azimuth = track.azimuth
	mov.current_elevation = track.elevation
	mov.current_distance = track.distance
	track_position_updated.emit(track.id, track.azimuth, track.elevation, track.distance)

func _apply_jump_movement(track: SoundscapeData.TrackConfig) -> void:
	var mov: SoundscapeData.MovementConfig = track.movement
	match mov.pattern:
		SoundscapeData.MovementPattern.PING_PONG_LR:
			if mov.direction > 0:
				track.azimuth = mov.max_azimuth
				mov.direction = -1.0
			else:
				track.azimuth = mov.min_azimuth
				mov.direction = 1.0
		SoundscapeData.MovementPattern.ONE_WAY_LR, SoundscapeData.MovementPattern.ONE_WAY_RL:
			track.azimuth = randf_range(mov.min_azimuth, mov.max_azimuth)
		SoundscapeData.MovementPattern.PING_PONG_FB:
			if mov.direction > 0:
				track.distance = mov.max_distance
				mov.direction = -1.0
			else:
				track.distance = mov.min_distance
				mov.direction = 1.0
		SoundscapeData.MovementPattern.ONE_WAY_FB, SoundscapeData.MovementPattern.ONE_WAY_BF:
			track.distance = randf_range(mov.min_distance, mov.max_distance)
		SoundscapeData.MovementPattern.ORBIT_CW:
			track.azimuth = wrapf(track.azimuth + 45.0, -180.0, 180.0)
		SoundscapeData.MovementPattern.ORBIT_CCW:
			track.azimuth = wrapf(track.azimuth - 45.0, -180.0, 180.0)
		SoundscapeData.MovementPattern.SPIRAL_IN, SoundscapeData.MovementPattern.SPIRAL_OUT:
			track.azimuth = wrapf(track.azimuth + 60.0, -180.0, 180.0)
			track.distance = randf_range(mov.min_distance, mov.max_distance)
		SoundscapeData.MovementPattern.FIGURE_EIGHT:
			mov.wander_timer += 0.8
			var t: float = mov.wander_timer
			var a: float = maxf(mov.max_distance * 0.85, 2.0)
			var denom: float = 1.0 + sin(t) * sin(t)
			var fx: float = (a * cos(t)) / denom
			var fz: float = (a * sin(t) * cos(t)) / denom
			track.distance = maxf(sqrt(fx * fx + fz * fz), mov.min_distance)
			track.azimuth = rad_to_deg(atan2(fx, -fz))
		SoundscapeData.MovementPattern.RANDOM_WALK:
			# Jump to a random position within roam boundary
			track.azimuth = randf_range(mov.min_azimuth, mov.max_azimuth)
			track.distance = randf_range(mov.min_distance, mov.max_distance)

	mov.current_azimuth = track.azimuth
	mov.current_distance = track.distance
	track_position_updated.emit(track.id, track.azimuth, track.elevation, track.distance)

var _listener_path_t: float = 0.0
var _listener_path_dir: float = 1.0

func _update_listener_path(delta: float) -> void:
	if _project == null or not _project.listener_path.enabled or _project.listener_path.points.size() < 2:
		return

	var path: SoundscapeData.ListenerPathConfig = _project.listener_path
	var pts: Array[Vector3] = path.points

	var total_len: float = 0.0
	for i in range(pts.size() - 1):
		total_len += pts[i].distance_to(pts[i + 1])
	if path.loop and pts.size() > 2:
		total_len += pts[pts.size() - 1].distance_to(pts[0])
	total_len = maxf(total_len, 0.1)

	# path.speed is in meters per second (m/s)
	var speed_ms: float = maxf(path.speed, 0.05)
	var progress_delta: float = (speed_ms / total_len) * delta

	if path.loop:
		_listener_path_t = wrapf(_listener_path_t + progress_delta, 0.0, 1.0)
	else:
		# Ping-pong along open path from Start to End smoothly without jumping
		_listener_path_t += _listener_path_dir * progress_delta
		if _listener_path_t >= 1.0:
			_listener_path_t = 1.0
			_listener_path_dir = -1.0
		elif _listener_path_t <= 0.0:
			_listener_path_t = 0.0
			_listener_path_dir = 1.0

	var listener_pos: Vector3 = _get_listener_path_pos(_listener_path_t)
	if _listener_3d:
		_listener_3d.position = listener_pos
	if _camera_3d:
		_camera_3d.position = listener_pos

	listener_position_updated.emit(listener_pos, _listener_path_t)

func _get_listener_path_pos(t: float) -> Vector3:
	if _project == null or _project.listener_path.points.size() < 2:
		return Vector3.ZERO
	var pts: Array[Vector3] = _project.listener_path.points
	var seg_count: int = pts.size() - 1 if not _project.listener_path.loop else pts.size()
	if seg_count <= 0: return pts[0]
	var total_t: float = t * float(seg_count)
	var seg_idx: int = clampi(int(total_t), 0, seg_count - 1)
	var seg_frac: float = total_t - float(seg_idx)
	var p1: Vector3 = pts[seg_idx]
	var p2: Vector3 = pts[(seg_idx + 1) % pts.size()] if _project.listener_path.loop else pts[mini(seg_idx + 1, pts.size() - 1)]
	return p1.lerp(p2, seg_frac)

func _update_player_3d_position(track: SoundscapeData.TrackConfig, player: AudioStreamPlayer3D) -> void:
	if track.channel_mode == SoundscapeData.ChannelRoutingMode.MULTI_CHANNEL and not track.target_channels.is_empty():
		var total_pos: Vector3 = Vector3.ZERO
		for ch in track.target_channels:
			match ch:
				"FL": total_pos += Vector3(-2.5, 0, -2.5)
				"FR": total_pos += Vector3(2.5, 0, -2.5)
				"FC": total_pos += Vector3(0, 0, -3.0)
				"LFE": total_pos += Vector3(0, -1.0, -1.0)
				"BL": total_pos += Vector3(-2.5, 0, 2.5)
				"BR": total_pos += Vector3(2.5, 0, 2.5)
				"SL": total_pos += Vector3(-3.5, 0, 0)
				"SR": total_pos += Vector3(3.5, 0, 0)
		player.position = total_pos / float(track.target_channels.size())
		return

	# Convert spherical (Azimuth, Elevation, Distance) to Cartesian (X, Y, Z)
	# Godot coordinates: -Z is Forward, +X is Right, +Y is Up
	# Azimuth 0 = Front (-Z), 90 = Right (+X), -90 = Left (-X), 180/-180 = Back (+Z)
	var az_rad: float = deg_to_rad(track.azimuth)
	var el_rad: float = deg_to_rad(track.elevation)
	var dist: float = maxf(track.distance, 0.1)

	var x: float = dist * cos(el_rad) * sin(az_rad)
	var y: float = dist * sin(el_rad)
	var z: float = -dist * cos(el_rad) * cos(az_rad)

	player.position = Vector3(x, y, z)

	if acoustic_env and _project:
		var sound_pos_2d: Vector2 = Vector2(x, z)
		var listener_pos_2d: Vector2 = Vector2(_listener_3d.position.x, _listener_3d.position.z) if _listener_3d else Vector2.ZERO
		var occ: float = acoustic_env.calculate_occlusion(sound_pos_2d, listener_pos_2d)
		var effective_vol: float = track.volume if not track.muted else 0.0
		var master_vol: float = _project.master_volume if _project else 1.0
		var base_db: float = linear_to_db(effective_vol * master_vol) if effective_vol > 0.0001 else -80.0
		if occ < 0.99:
			player.volume_db = maxf(-80.0, base_db + linear_to_db(occ) * 0.4)
		else:
			player.volume_db = base_db

func _get_track_by_id(id: String) -> SoundscapeData.TrackConfig:
	for t in _project.tracks:
		if t.id == id:
			return t
	return null

func set_track_volume(track_id: String, vol: float) -> void:
	var track: SoundscapeData.TrackConfig = _get_track_by_id(track_id)
	if track:
		track.volume = vol
		update_track_volume(track)

func set_track_position(track_id: String, azimuth: float, elevation: float, distance: float) -> void:
	var track: SoundscapeData.TrackConfig = _get_track_by_id(track_id)
	if track:
		track.azimuth = azimuth
		track.elevation = elevation
		track.distance = distance
		if _audio_players.has(track_id) and _audio_players[track_id] is AudioStreamPlayer3D:
			_update_player_3d_position(track, _audio_players[track_id])
		track_position_updated.emit(track_id, azimuth, elevation, distance)

func set_speaker_layout(layout: SpeakerLayouts.LayoutType) -> void:
	speaker_layout = layout
	if _project: _project.speaker_layout = layout

func set_master_volume(vol: float) -> void:
	if _project:
		_project.master_volume = vol
		for track in _project.tracks:
			update_track_volume(track)

func set_listener_path(path: SoundscapeData.ListenerPathConfig) -> void:
	if _project:
		_project.listener_path = path

func remove_track(track_id: String) -> void:
	if _audio_players.has(track_id):
		var p: Node = _audio_players[track_id]
		p.queue_free()
		_audio_players.erase(track_id)
	_schedulers.erase(track_id)
	_streams.erase(track_id)

func update_track_volume(track: SoundscapeData.TrackConfig) -> void:
	if track == null: return
	if _audio_players.has(track.id):
		var p: Node = _audio_players[track.id]
		var effective_vol: float = track.volume if not track.muted else 0.0
		var master_vol: float = _project.master_volume if _project else 1.0
		var db: float = linear_to_db(effective_vol * master_vol) if effective_vol > 0.0001 else -80.0
		if p is AudioStreamPlayer3D:
			p.volume_db = db
		elif p is AudioStreamPlayer:
			p.volume_db = db
		if _is_playing and not track.muted and not p.playing and track.trigger.mode == SoundscapeData.TriggerMode.CONTINUOUS_LOOP:
			p.play()

func update_track_spatial_position(track: SoundscapeData.TrackConfig) -> void:
	if track == null: return
	set_track_position(track.id, track.azimuth, track.elevation, track.distance)

func get_listener_position() -> Vector3:
	if _listener_3d:
		return _listener_3d.position
	return Vector3.ZERO

