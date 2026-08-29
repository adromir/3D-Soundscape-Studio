class_name AutomationCanvas
extends Control

# Author: Adromir
# Repository: https://github.com/adromir

signal path_updated()
signal listener_scrubbed(pos: Vector3)

var project: SoundscapeData.SoundscapeProject = null
var _selected_point_idx: int = -1
var _dragging_point_idx: int = -1
var _playhead_t: float = 0.0 # 0.0 to 1.0 along the path
var soundspace_max_distance: float = 12.0

func _ready() -> void:
	custom_minimum_size = Vector2(300, 250)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	clip_contents = true

func set_project(proj: SoundscapeData.SoundscapeProject) -> void:
	project = proj
	if project:
		soundspace_max_distance = project.soundspace_radius
	queue_redraw()

func set_playhead(t: float) -> void:
	_playhead_t = clampf(t, 0.0, 1.0)
	queue_redraw()

func set_soundspace_max_distance(dist: float) -> void:
	soundspace_max_distance = clampf(dist, 2.0, 100.0)
	if project:
		project.soundspace_radius = soundspace_max_distance
		# Strictly clamp existing waypoints within the new soundspace boundary
		for i in range(project.listener_path.points.size()):
			var pt: Vector3 = project.listener_path.points[i]
			var dist_2d: float = Vector2(pt.x, pt.z).length()
			if dist_2d > soundspace_max_distance:
				var dir: Vector2 = Vector2(pt.x, pt.z).normalized()
				project.listener_path.points[i] = Vector3(dir.x * soundspace_max_distance, pt.y, dir.y * soundspace_max_distance)
	path_updated.emit()
	queue_redraw()

func _draw() -> void:
	var pal: Dictionary = ThemeManager.get_palette()
	var center: Vector2 = size * 0.5
	var available_r: float = minf(center.x, center.y) - 16.0
	var radius: float = maxf(available_r, 80.0)

	# 1. Background Grid & Coordinates
	draw_circle(center, radius, pal["canvas_bg"])
	draw_arc(center, radius, 0, TAU, 64, pal["panel_border_glow"], 1.8, true)

	for i in range(1, 4):
		var r: float = radius * (float(i) / 3.0)
		draw_arc(center, r, 0, TAU, 48, pal["canvas_grid"], 1.0, true)

	draw_line(center - Vector2(radius, 0), center + Vector2(radius, 0), pal["canvas_grid"], 1.0, true)
	draw_line(center - Vector2(0, radius), center + Vector2(0, radius), pal["canvas_grid"], 1.0, true)

	# Soundspace Radius Badge
	var scale_badge_rect: Rect2 = Rect2(Vector2(size.x - 130, 10), Vector2(120, 24))
	draw_rect(scale_badge_rect, pal["panel_bg"], true)
	draw_rect(scale_badge_rect, pal["panel_border"], false, 1.0)
	draw_string(ThemeDB.fallback_font, scale_badge_rect.position + Vector2(8, 16), "🔍 Radius: %.0fm" % soundspace_max_distance, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, pal["text_main"])

	# Bottom instructions hint
	var hint_text: String = "Left-Click inside circle to add Waypoints  |  Drag to move  |  Right-Click to delete"
	draw_string(ThemeDB.fallback_font, Vector2(16, size.y - 12), hint_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, pal["text_dim"])

	if project == null:
		return

	# 2. Draw Static Sound Sources for reference
	for track in project.tracks:
		var ang_rad: float = deg_to_rad(track.azimuth - 90.0)
		var r: float = clampf(track.distance / soundspace_max_distance, 0.08, 0.95) * radius
		var pos: Vector2 = center + Vector2(cos(ang_rad), sin(ang_rad)) * r
		var trk_col: Color = Color.from_string(track.color_hex, pal["primary"])
		trk_col.a = 0.6
		draw_circle(pos, 6.0, trk_col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(-30, 14), track.name, HORIZONTAL_ALIGNMENT_CENTER, 60, 10, pal["text_dim"])

	# 3. Draw Listener Path Waypoints and Connections
	var pts: Array[Vector3] = project.listener_path.points
	if pts.size() >= 2:
		var path_color: Color = pal["primary"]
		for i in range(pts.size() - 1):
			var p1: Vector2 = _world_to_canvas(pts[i], center, radius)
			var p2: Vector2 = _world_to_canvas(pts[i + 1], center, radius)
			draw_line(p1, p2, path_color, 2.5, true)

		# Only draw closing loop line if loop is explicitly enabled
		if project.listener_path.loop and pts.size() > 2:
			var p_first: Vector2 = _world_to_canvas(pts[0], center, radius)
			var p_last: Vector2 = _world_to_canvas(pts[pts.size() - 1], center, radius)
			var loop_col: Color = path_color
			loop_col.a = 0.5
			draw_line(p_last, p_first, loop_col, 1.8, true)

	# 4. Draw Waypoint Nodes with Start/End badges
	for i in range(pts.size()):
		var p_screen: Vector2 = _world_to_canvas(pts[i], center, radius)
		var is_sel: bool = (i == _selected_point_idx)
		var is_start: bool = (i == 0)
		var is_end: bool = (i == pts.size() - 1 and not project.listener_path.loop and pts.size() > 1)

		var node_col: Color = pal["secondary"]
		var label_str: String = "#%d" % (i + 1)
		if is_start:
			node_col = Color("#00e676") # Green Start
			label_str = "#1 START"
		elif is_end:
			node_col = Color("#ff5252") # Coral End
			label_str = "#%d END" % (i + 1)
		elif is_sel:
			node_col = pal["tertiary"]

		draw_circle(p_screen, 7.0 if is_sel else 5.5, node_col)
		draw_arc(p_screen, 7.0 if is_sel else 5.5, 0, TAU, 24, Color.WHITE if is_sel else pal["bg_base"], 1.5, true)
		draw_string(ThemeDB.fallback_font, p_screen + Vector2(8, -4), label_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, node_col if (is_start or is_end) else pal["text_dim"])

	# 5. Draw Animated Listener Head on Path
	if pts.size() >= 2:
		var listener_pos_3d: Vector3 = _get_interpolated_path_pos(_playhead_t)
		var listener_screen: Vector2 = _world_to_canvas(listener_pos_3d, center, radius)
		draw_circle(listener_screen, 12.0, Color(pal["primary"].r, pal["primary"].g, pal["primary"].b, 0.35))
		draw_circle(listener_screen, 7.0, pal["primary"])
		draw_arc(listener_screen, 7.0, 0, TAU, 24, Color.WHITE, 1.5, true)

func _world_to_canvas(pt: Vector3, center: Vector2, radius: float) -> Vector2:
	var factor: float = radius / soundspace_max_distance
	return center + Vector2(pt.x * factor, -pt.z * factor)

func _canvas_to_world(pos: Vector2, center: Vector2, radius: float) -> Vector3:
	var factor: float = soundspace_max_distance / radius
	var delta: Vector2 = pos - center
	# Strictly clamp to within soundspace circle
	if delta.length() > radius:
		delta = delta.normalized() * radius
	return Vector3(delta.x * factor, 0.0, -delta.y * factor)

func _get_interpolated_path_pos(t: float) -> Vector3:
	if project == null or project.listener_path.points.size() < 2:
		return Vector3.ZERO
	var pts: Array[Vector3] = project.listener_path.points
	var seg_count: int = pts.size() - 1 if not project.listener_path.loop else pts.size()
	if seg_count <= 0: return pts[0]
	var total_t: float = t * float(seg_count)
	var seg_idx: int = clampi(int(total_t), 0, seg_count - 1)
	var seg_frac: float = total_t - float(seg_idx)

	var p1: Vector3 = pts[seg_idx]
	var p2: Vector3 = pts[(seg_idx + 1) % pts.size()] if project.listener_path.loop else pts[mini(seg_idx + 1, pts.size() - 1)]
	return p1.lerp(p2, seg_frac)

func _gui_input(event: InputEvent) -> void:
	if project == null:
		return

	var center: Vector2 = size * 0.5
	var available_r: float = minf(center.x, center.y) - 16.0
	var radius: float = maxf(available_r, 80.0)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			set_soundspace_max_distance(soundspace_max_distance - (2.0 if soundspace_max_distance <= 20.0 else 5.0))
			accept_event()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			set_soundspace_max_distance(soundspace_max_distance + (2.0 if soundspace_max_distance < 20.0 else 5.0))
			accept_event()
			return
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var hit_idx: int = -1
				for i in range(project.listener_path.points.size()):
					var p_screen: Vector2 = _world_to_canvas(project.listener_path.points[i], center, radius)
					if event.position.distance_to(p_screen) <= 12.0:
						hit_idx = i
						break

				if hit_idx != -1:
					_selected_point_idx = hit_idx
					_dragging_point_idx = hit_idx
				else:
					# Add new waypoint only if clicked within/near soundspace circle
					if event.position.distance_to(center) <= radius + 10.0:
						var new_pt: Vector3 = _canvas_to_world(event.position, center, radius)
						project.listener_path.points.append(new_pt)
						_selected_point_idx = project.listener_path.points.size() - 1
						_dragging_point_idx = _selected_point_idx
						project.listener_path.enabled = true
						path_updated.emit()
				queue_redraw()
			else:
				_dragging_point_idx = -1

		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Remove clicked waypoint
			for i in range(project.listener_path.points.size()):
				var p_screen: Vector2 = _world_to_canvas(project.listener_path.points[i], center, radius)
				if event.position.distance_to(p_screen) <= 12.0:
					project.listener_path.points.remove_at(i)
					_selected_point_idx = -1
					path_updated.emit()
					queue_redraw()
					break

	elif event is InputEventMouseMotion:
		if _dragging_point_idx >= 0 and _dragging_point_idx < project.listener_path.points.size():
			project.listener_path.points[_dragging_point_idx] = _canvas_to_world(event.position, center, radius)
			path_updated.emit()
			queue_redraw()
