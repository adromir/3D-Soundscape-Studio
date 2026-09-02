class_name LightingEngine
extends Node

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio



var ha_client: HomeAssistantClient = null
var hue_client: PhilipsHueClient = null
var project_lighting: SoundscapeData.LightingProjectConfig = null
var is_active: bool = false

var _flicker_time: float = 0.0
var _update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.20 # 5 Hz network update rate to avoid flood

var _last_sent_brightness: Dictionary = {} # entity_id -> int
var _last_sent_time: Dictionary = {} # entity_id -> float

func _ready() -> void:
	ha_client = HomeAssistantClient.new()
	ha_client.name = "HAClient"
	add_child(ha_client)

	hue_client = PhilipsHueClient.new()
	hue_client.name = "HueClient"
	add_child(hue_client)

func set_project_lighting(cfg: SoundscapeData.LightingProjectConfig) -> void:
	project_lighting = cfg
	_last_sent_brightness.clear()
	_last_sent_time.clear()
	if project_lighting:
		ha_client.configure(project_lighting.ha_endpoint, project_lighting.ha_token)
		hue_client.configure(project_lighting.hue_bridge_ip, project_lighting.hue_username)

func start_playback() -> void:
	if project_lighting == null or not project_lighting.enabled:
		return
	is_active = true
	_last_sent_brightness.clear()
	_last_sent_time.clear()
	apply_baseline_lighting()

func stop_playback() -> void:
	if not is_active:
		return
	is_active = false
	_last_sent_brightness.clear()
	_last_sent_time.clear()
	if project_lighting and project_lighting.enabled:
		var is_hue: bool = (project_lighting.backend == SoundscapeData.LightingProjectConfig.BackendType.PHILIPS_HUE)
		for l in project_lighting.lights:
			if l.enabled and not l.entity_id.is_empty():
				if is_hue:
					hue_client.turn_off_light(l.entity_id, 1.0)
				else:
					ha_client.turn_off_light(l.entity_id, 1.0)

func apply_baseline_lighting() -> void:
	if project_lighting == null or not project_lighting.enabled:
		return

	var is_hue: bool = (project_lighting.backend == SoundscapeData.LightingProjectConfig.BackendType.PHILIPS_HUE)
	for l in project_lighting.lights:
		if l.enabled and not l.entity_id.is_empty():
			_last_sent_brightness[l.entity_id] = l.brightness_pct
			_last_sent_time[l.entity_id] = Time.get_ticks_msec() / 1000.0
			if is_hue:
				hue_client.turn_on_light(l.entity_id, l.base_rgb, l.brightness_pct, 1.0)
			else:
				ha_client.turn_on_light(l.entity_id, l.base_rgb, l.brightness_pct, 1.0)

func on_sound_triggered(track_id: String) -> void:
	if not is_active or project_lighting == null or not project_lighting.enabled:
		return

	var is_hue: bool = (project_lighting.backend == SoundscapeData.LightingProjectConfig.BackendType.PHILIPS_HUE)
	for l in project_lighting.lights:
		if l.enabled and not l.entity_id.is_empty():
			if l.trigger_track_id == track_id or l.effect_mode == SoundscapeData.LightEffectMode.LIGHTNING_TRIGGER_FLASH:
				if is_hue:
					hue_client.trigger_lightning_flash(l.entity_id, l.flash_color, l.base_rgb, l.brightness_pct, l.flash_duration_ms)
				else:
					ha_client.trigger_lightning_flash(l.entity_id, l.flash_color, l.base_rgb, l.brightness_pct, l.flash_duration_ms)

func update_frame(delta: float, listener_pos: Vector3) -> void:
	if not is_active or project_lighting == null or not project_lighting.enabled:
		return

	_flicker_time += delta
	_update_timer += delta
	if _update_timer < UPDATE_INTERVAL:
		return
	_update_timer = 0.0

	for l in project_lighting.lights:
		if not l.enabled or l.entity_id.is_empty():
			continue

		match l.effect_mode:
			SoundscapeData.LightEffectMode.CANDLE_HEARTH_FLICKER:
				var flicker: float = sin(_flicker_time * 7.5) * 0.08 + sin(_flicker_time * 19.3) * 0.05
				var flicker_pct: int = clamp(int(l.brightness_pct * (1.0 + flicker)), 1, 100)
				_send_throttled_light_update(l.entity_id, l.base_rgb, flicker_pct, 0.25)

			SoundscapeData.LightEffectMode.PROXIMITY_WALK:
				var dist: float = listener_pos.distance_to(l.position_3d)
				var atten: float = clampf(1.0 - (dist / 8.0), 0.15, 1.0)
				var prox_pct: int = clamp(int(l.brightness_pct * atten), 5, 100)
				_send_throttled_light_update(l.entity_id, l.base_rgb, prox_pct, 0.30)

func _send_throttled_light_update(entity_id: String, rgb: Color, brightness_pct: int, transition: float) -> void:
	var now: float = float(Time.get_ticks_msec()) / 1000.0
	var last_br: int = _last_sent_brightness.get(entity_id, -999)
	var last_time: float = _last_sent_time.get(entity_id, 0.0)

	# Only send if brightness delta is >= 3% or at least 1.5 seconds have elapsed
	if absi(last_br - brightness_pct) < 3 and (now - last_time) < 1.5:
		return

	_last_sent_brightness[entity_id] = brightness_pct
	_last_sent_time[entity_id] = now

	if project_lighting and project_lighting.backend == SoundscapeData.LightingProjectConfig.BackendType.PHILIPS_HUE:
		hue_client.turn_on_light(entity_id, rgb, brightness_pct, transition)
	else:
		ha_client.turn_on_light(entity_id, rgb, brightness_pct, transition)
