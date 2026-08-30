class_name SpatialCanvas
extends Control

# Author: Adromir
# Repository: https://github.com/adromir

signal track_selected(track_id: String)
signal track_position_changed(track_id: String, azimuth: float, elevation: float, distance: float)
signal sample_dropped(sample_name: String, sample_path: String, azimuth: float, distance: float)

var project: SoundscapeData.SoundscapeProject = null
var selected_track_id: String = ""

var _dragging_track_id: String = ""
var _hovered_track_id: String = ""
var soundspace_max_distance: float = 10.0
var radar_sweep_enabled: bool = true
var _active_pulses: Dictionary = {} # track_id -> pulse_progress (0.0 to 1.0)
var _radar_sweep_angle: float = 0.0 # Radians for animated sweep
var _icon_textures: Dictionary = {}
var _empty_text: String = "No audio tracks yet\nDrop audio or click + Add Track"

func _get_icon_texture(icon_name: String) -> Texture2D:
	if _icon_textures.has(icon_name):
		return _icon_textures[icon_name]
	var tex: Texture2D = ThemeManager.get_sound_icon(icon_name, true)
	if tex:
		_icon_textures[icon_name] = tex
		return tex
	return null

func _ready() -> void:
	custom_minimum_size = Vector2(200, 200)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	clip_contents = true
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(func():
		_hovered_track_id = ""
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		queue_redraw()
	)
	update_localization()

func update_localization() -> void:
	_empty_text = LocalizationData.tr_key("EMPTY_TRACKS_TITLE") if LocalizationData.tr_key("EMPTY_TRACKS_TITLE") != "EMPTY_TRACKS_TITLE" else "No audio tracks yet"
	queue_redraw()

func set_project(proj: SoundscapeData.SoundscapeProject) -> void:
	project = proj
	if project:
		soundspace_max_distance = project.soundspace_radius
	queue_redraw()

func select_track(track_id: String) -> void:
	selected_track_id = track_id
	queue_redraw()

func trigger_pulse(track_id: String) -> void:
	_active_pulses[track_id] = 1.0
	queue_redraw()

func set_radar_sweep_enabled(enabled: bool) -> void:
	radar_sweep_enabled = enabled
	queue_redraw()

signal soundspace_radius_changed(radius: float)

func set_soundspace_max_distance(dist: float) -> void:
	var old_dist: float = soundspace_max_distance
	soundspace_max_distance = clampf(dist, 2.0, 100.0)
	if project:
		project.soundspace_radius = soundspace_max_distance
	if not is_equal_approx(old_dist, soundspace_max_distance):
		soundspace_radius_changed.emit(soundspace_max_distance)
	queue_redraw()

func _process(delta: float) -> void:
	var needs_redraw: bool = false

	if radar_sweep_enabled:
		_radar_sweep_angle = wrapf(_radar_sweep_angle + (delta * 1.25), 0.0, TAU)
		needs_redraw = true

	if not _active_pulses.is_empty():
		needs_redraw = true
		var finished_pulses: Array[String] = []
		for id in _active_pulses.keys():
			_active_pulses[id] -= delta * 1.6
			if _active_pulses[id] <= 0.0:
				finished_pulses.append(id)

		for id in finished_pulses:
			_active_pulses.erase(id)

	if project:
		for t in project.tracks:
			if t.movement and t.movement.pattern != SoundscapeData.MovementPattern.NONE and not t.muted:
				needs_redraw = true
				break

	if needs_redraw:
		queue_redraw()

func _draw() -> void:
	var pal: Dictionary = ThemeManager.get_palette()
	var center: Vector2 = size * 0.5
	var available_r: float = minf(center.x, center.y) - 16.0
	var radius: float = maxf(available_r, 80.0)

	if radius <= 10.0:
		return

	# 1. Liquid Glass Lens Base
	var bg_color: Color = pal["canvas_bg"]
	draw_circle(center, radius, bg_color)

	# Lens rim glow (Liquid Glass Reflection)
	var rim_color: Color = pal["panel_border_glow"]
	rim_color.a = 0.35
	draw_arc(center, radius, 0, TAU, 96, rim_color, 2.0, true)

	# 2. Rotating Radar Phosphor Sweep (Optional Liquid Beam)
	if radar_sweep_enabled:
		var sweep_segments: int = 32
		var sweep_arc: float = 0.5 # ~28 degrees
		for s in range(sweep_segments):
			var frac: float = float(s) / float(sweep_segments)
			var a1: float = _radar_sweep_angle - (sweep_arc * (1.0 - frac))
			var a2: float = a1 + (sweep_arc / float(sweep_segments))
			var col_sweep: Color = pal["canvas_radar_sweep"]
			col_sweep.a *= (frac * frac * 1.2) # Non-linear phosphor glow
			var pts: PackedVector2Array = [
				center,
				center + Vector2(cos(a1), sin(a1)) * radius,
				center + Vector2(cos(a2), sin(a2)) * radius
			]
			draw_colored_polygon(pts, col_sweep)

	# 3. Concentric Polar Distance Rings & Grid Lines
	var rings: int = 4
	for i in range(1, rings + 1):
		var r: float = radius * (float(i) / float(rings))
		var ring_color: Color = pal["canvas_grid"]
		ring_color.a = 0.45 if i == rings else 0.22
		draw_arc(center, r, 0, TAU, 96, ring_color, 1.2, true)

		# Distance label with liquid glow badge
		var dist_val: float = soundspace_max_distance * (float(i) / float(rings))
		var lbl_pos: Vector2 = center + Vector2(6, -r + 14)
		draw_string(ThemeDB.fallback_font, lbl_pos, "%.1fm" % dist_val, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, pal["text_dim"])

	# 8 Radial Crosshair Lines
	var radial_lines: int = 8
	for r_idx in range(radial_lines):
		var ang: float = float(r_idx) * (TAU / float(radial_lines))
		var line_end: Vector2 = center + Vector2(cos(ang), sin(ang)) * radius
		var is_cardinal: bool = (r_idx % 2 == 0)
		var line_col: Color = pal["canvas_grid"]
		line_col.a = 0.5 if is_cardinal else 0.18
		draw_line(center, line_end, line_col, 1.0 if not is_cardinal else 1.5, true)

	# Cardinal Orientation Badges (F, B, L, R)
	var f_color: Color = pal["primary"]
	var dim_color: Color = pal["text_dim"]
	draw_string(ThemeDB.fallback_font, Vector2(center.x - 4, center.y - radius + 16), "F", HORIZONTAL_ALIGNMENT_CENTER, -1, 13, f_color)
	draw_string(ThemeDB.fallback_font, Vector2(center.x - 4, center.y + radius - 6), "B", HORIZONTAL_ALIGNMENT_CENTER, -1, 13, dim_color)
	draw_string(ThemeDB.fallback_font, Vector2(center.x - radius + 8, center.y + 4), "L", HORIZONTAL_ALIGNMENT_CENTER, -1, 13, dim_color)
	draw_string(ThemeDB.fallback_font, Vector2(center.x + radius - 16, center.y + 4), "R", HORIZONTAL_ALIGNMENT_CENTER, -1, 13, dim_color)

	# 4. Central Listener Avatar with Pulsing Liquid Core
	var listener_col: Color = pal["primary"]
	var listener_glow: Color = pal["primary"]
	listener_glow.a = 0.35
	draw_circle(center, 18.0, listener_glow)
	draw_circle(center, 9.0, listener_col)
	# Direction arrow
	draw_line(center, center + Vector2(0, -18), listener_col, 2.5, true)
	draw_line(center + Vector2(-5, -13), center + Vector2(0, -18), listener_col, 2.0, true)
	draw_line(center + Vector2(5, -13), center + Vector2(0, -18), listener_col, 2.0, true)

	if project == null or project.tracks.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(center.x - 70, center.y + 40), _empty_text, HORIZONTAL_ALIGNMENT_CENTER, 140, 11, pal["text_dim"])
		return

	# 5. Omnipresent Atmosphere Rings
	var has_omni: bool = false
	for track in project.tracks:
		if track.channel_mode == SoundscapeData.ChannelRoutingMode.OMNIPRESENT and not track.muted:
			has_omni = true
			break

	if has_omni:
		var omni_col: Color = pal["secondary"]
		omni_col.a = 0.35
		draw_arc(center, radius - 4.0, 0, TAU, 96, omni_col, 5.0, true)

	# 6. Draw Track Sound Source Nodes with Liquid Aura
	for track in project.tracks:
		var pos: Vector2 = _get_screen_position_for_track(track, center, radius)
		var is_sel: bool = (track.id == selected_track_id)
		var is_hover: bool = (track.id == _hovered_track_id)

		var custom_color: Color = Color.from_string(track.color_hex, pal["primary"])
		var node_color: Color = pal["tertiary"] if is_sel else (pal["text_dim"] if track.muted else custom_color)
		if is_hover and not is_sel:
			node_color = custom_color.lightened(0.25)

		# Draw movement path preview
		if track.movement.pattern != SoundscapeData.MovementPattern.NONE:
			_draw_movement_preview(track, center, radius, pal)

		# Multi-layer pulse wave animation on trigger
		if _active_pulses.has(track.id):
			var pulse: float = 1.0 - _active_pulses[track.id]
			for p_ring in range(3):
				var r_offset: float = float(p_ring) * 7.0
				var pulse_r: float = 14.0 + (pulse * 40.0) + r_offset
				var p_col: Color = node_color
				p_col.a = (1.0 - pulse) * (0.9 / float(p_ring + 1))
				draw_arc(pos, pulse_r, 0, TAU, 48, p_col, 2.0, true)

		# Outer Liquid Glow Aura
		var glow_col: Color = node_color
		glow_col.a = 0.45 if (is_sel or is_hover) else 0.22
		var halo_r: float = 32.0 if is_hover else (28.0 if is_sel else 22.0)
		draw_circle(pos, halo_r, glow_col)

		if is_hover or is_sel:
			var rim_aura: Color = Color.WHITE
			rim_aura.a = 0.65
			draw_arc(pos, halo_r, 0, TAU, 36, rim_aura, 1.5, true)

		# Core node circle
		var core_r: float = 18.0 if (is_sel or is_hover) else 14.5
		draw_circle(pos, core_r, node_color)
		draw_arc(pos, core_r, 0, TAU, 32, Color.WHITE if (is_sel or is_hover) else pal["bg_base"], 2.0, true)

		# Sound Icon inside Node (black/dark icon inside glowing colored marker)
		var tex: Texture2D = _get_icon_texture(track.icon_name)
		if tex:
			var icon_size: Vector2 = Vector2(22, 22) if (is_sel or is_hover) else Vector2(17, 17)
			var icon_rect: Rect2 = Rect2(pos - (icon_size * 0.5), icon_size)
			draw_texture_rect(tex, icon_rect, false, Color(0.04, 0.06, 0.10, 0.95))

		# Vector line to center when selected
		if is_sel:
			var vec_col: Color = pal["tertiary"]
			vec_col.a = 0.45
			draw_line(center, pos, vec_col, 1.5, true)

		# Label Card
		var label_text: String = track.name
		var text_col: Color = Color.WHITE if (is_sel or is_hover) else pal["text_dim"]
		draw_string(ThemeDB.fallback_font, pos + Vector2(-40, core_r + 15), label_text, HORIZONTAL_ALIGNMENT_CENTER, 80, 11, text_col)

func _draw_movement_preview(track: SoundscapeData.TrackConfig, center: Vector2, radius: float, pal: Dictionary) -> void:
	var mov: SoundscapeData.MovementConfig = track.movement
	var trail_color: Color = pal["secondary"]
	trail_color.a = 0.55

	match mov.pattern:
		SoundscapeData.MovementPattern.PING_PONG_LR, SoundscapeData.MovementPattern.ONE_WAY_LR:
			var start_ang: float = deg_to_rad(mov.min_azimuth - 90.0)
			var end_ang: float = deg_to_rad(mov.max_azimuth - 90.0)
			var r: float = (track.distance / soundspace_max_distance) * radius
			draw_arc(center, r, start_ang, end_ang, 48, trail_color, 2.2, true)
		SoundscapeData.MovementPattern.PING_PONG_FB, SoundscapeData.MovementPattern.ONE_WAY_FB:
			var az_rad: float = deg_to_rad(track.azimuth - 90.0)
			var r_min: float = (mov.min_distance / soundspace_max_distance) * radius
			var r_max: float = (mov.max_distance / soundspace_max_distance) * radius
			var p1: Vector2 = center + Vector2(cos(az_rad), sin(az_rad)) * r_min
			var p2: Vector2 = center + Vector2(cos(az_rad), sin(az_rad)) * r_max
			draw_line(p1, p2, trail_color, 2.2, true)
		SoundscapeData.MovementPattern.RANDOM_WALK:
			var az_rad: float = deg_to_rad(track.azimuth - 90.0)
			var r: float = (track.distance / soundspace_max_distance) * radius
			var p: Vector2 = center + Vector2(cos(az_rad), sin(az_rad)) * r
			draw_arc(p, 18.0, 0, TAU, 24, trail_color, 1.5, true)

func _get_screen_position_for_track(track: SoundscapeData.TrackConfig, center: Vector2, max_r: float) -> Vector2:
	if track.channel_mode == SoundscapeData.ChannelRoutingMode.OMNIPRESENT:
		var ang_rad: float = deg_to_rad(track.azimuth - 90.0)
		return center + Vector2(cos(ang_rad), sin(ang_rad)) * (max_r - 6.0)

	var ang_rad: float = deg_to_rad(track.azimuth - 90.0)
	var r: float = clampf(track.distance / soundspace_max_distance, 0.08, 0.95) * max_r
	return center + Vector2(cos(ang_rad), sin(ang_rad)) * r

func _gui_input(event: InputEvent) -> void:
	if project == null:
		return

	var center: Vector2 = size * 0.5
	var available_r: float = minf(center.x, center.y) - 16.0
	var radius: float = maxf(available_r, 80.0)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Zoom in (closer view)
			set_soundspace_max_distance(soundspace_max_distance - (2.0 if soundspace_max_distance <= 20.0 else 5.0))
			accept_event()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Zoom out (expand soundspace view)
			set_soundspace_max_distance(soundspace_max_distance + (2.0 if soundspace_max_distance < 20.0 else 5.0))
			accept_event()
			return
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var clicked_track: SoundscapeData.TrackConfig = null
				for track in project.tracks:
					var pos: Vector2 = _get_screen_position_for_track(track, center, radius)
					if event.position.distance_to(pos) <= 28.0:
						clicked_track = track
						break

				if clicked_track:
					_dragging_track_id = clicked_track.id
					selected_track_id = clicked_track.id
					track_selected.emit(selected_track_id)
					queue_redraw()
			else:
				_dragging_track_id = ""

	elif event is InputEventMouseMotion:
		if not _dragging_track_id.is_empty():
			var delta_pos: Vector2 = event.position - center
			var raw_dist_ratio: float = delta_pos.length() / radius
			var dist_ratio: float = clampf(raw_dist_ratio, 0.05, 1.0)
			var new_distance: float = dist_ratio * soundspace_max_distance

			var angle_rad: float = delta_pos.angle() + (PI * 0.5)
			var new_azimuth: float = wrapf(rad_to_deg(angle_rad), -180.0, 180.0)

			var track: SoundscapeData.TrackConfig = _find_track(_dragging_track_id)
			if track:
				track.azimuth = new_azimuth
				if track.channel_mode == SoundscapeData.ChannelRoutingMode.OMNIPRESENT:
					if raw_dist_ratio < 0.75:
						track.channel_mode = SoundscapeData.ChannelRoutingMode.POINT_3D
						track.distance = new_distance
				else:
					track.distance = new_distance

				track_position_changed.emit(track.id, track.azimuth, track.elevation, track.distance)
				queue_redraw()
		else:
			# Hover tracking
			var hovered: String = ""
			for track in project.tracks:
				var pos: Vector2 = _get_screen_position_for_track(track, center, radius)
				if event.position.distance_to(pos) <= 28.0:
					hovered = track.id
					break

			if hovered != _hovered_track_id:
				_hovered_track_id = hovered
				mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not hovered.is_empty() else Control.CURSOR_ARROW
				queue_redraw()

func _find_track(id: String) -> SoundscapeData.TrackConfig:
	if project == null:
		return null
	for t in project.tracks:
		if t.id == id:
			return t
	return null

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.get("type") == "sample":
		return true
	if data is PackedStringArray or data is Array:
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var center: Vector2 = size * 0.5
	var available_r: float = minf(center.x, center.y) - 16.0
	var radius: float = maxf(available_r, 80.0)

	var delta: Vector2 = at_position - center
	var dist_ratio: float = clampf(delta.length() / radius, 0.05, 1.0)
	var drop_distance: float = dist_ratio * soundspace_max_distance
	var angle_rad: float = delta.angle() + (PI * 0.5)
	var drop_azimuth: float = wrapf(rad_to_deg(angle_rad), -180.0, 180.0)

	if data is Dictionary and data.get("type") == "sample":
		var sample_name: String = data.get("name", "Audio Track")
		var sample_path: String = data.get("path", "")
		if not sample_path.is_empty():
			sample_dropped.emit(sample_name, sample_path, drop_azimuth, drop_distance)
	elif data is PackedStringArray or data is Array:
		for path_item in data:
			var s_path: String = str(path_item)
			var s_name: String = s_path.get_file().get_basename().replace("_", " ").capitalize()
			sample_dropped.emit(s_name, s_path, drop_azimuth, drop_distance)
