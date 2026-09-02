class_name PhilipsHueClient
extends Node

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

signal bridge_discovered(success: bool, bridge_ip: String, message: String)
signal pairing_status_changed(message: String, is_polling: bool, seconds_left: int)
signal pairing_completed(success: bool, username: String, message: String)
signal lights_fetched(lights: Array[Dictionary])
signal light_state_updated(light_id: String, success: bool)
signal error_occurred(error_msg: String)

var bridge_ip: String = ""
var username: String = ""

var _http_discovery: HTTPRequest = null
var _http_pair: HTTPRequest = null
var _http_fetch: HTTPRequest = null
var _http_cmd: HTTPRequest = null

var _is_pairing: bool = false
var _pair_seconds_left: int = 0
var _pair_timer: Timer = null

func _ready() -> void:
	_http_discovery = HTTPRequest.new()
	_http_discovery.name = "HueDiscoveryHTTP"
	_http_discovery.timeout = 5.0
	_http_discovery.request_completed.connect(_on_discovery_completed)
	add_child(_http_discovery)

	_http_pair = HTTPRequest.new()
	_http_pair.name = "HuePairHTTP"
	_http_pair.timeout = 3.0
	_http_pair.request_completed.connect(_on_pair_completed)
	add_child(_http_pair)

	_http_fetch = HTTPRequest.new()
	_http_fetch.name = "HueFetchHTTP"
	_http_fetch.timeout = 5.0
	_http_fetch.request_completed.connect(_on_fetch_completed)
	add_child(_http_fetch)

	_http_cmd = HTTPRequest.new()
	_http_cmd.name = "HueCmdHTTP"
	_http_cmd.timeout = 3.0
	_http_cmd.request_completed.connect(_on_cmd_completed)
	add_child(_http_cmd)

	_pair_timer = Timer.new()
	_pair_timer.name = "PairTimer"
	_pair_timer.wait_time = 1.0
	_pair_timer.one_shot = false
	_pair_timer.timeout.connect(_on_pair_poll_tick)
	add_child(_pair_timer)

func configure(ip: String, user: String) -> void:
	bridge_ip = ip.strip_edges().trim_prefix("http://").trim_prefix("https://").trim_suffix("/")
	username = user.strip_edges()

func discover_bridge() -> void:
	if _http_discovery.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_http_discovery.cancel_request()

	var url: String = "https://discovery.meethue.com/"
	var err: Error = _http_discovery.request(url)
	if err != OK:
		bridge_discovered.emit(false, "", "Failed to initiate cloud discovery request.")

func _on_discovery_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		bridge_discovered.emit(false, "", "Discovery failed with response code %d." % response_code)
		return

	var json: JSON = JSON.new()
	var parse_err: Error = json.parse(body.get_string_from_utf8())
	if parse_err != OK or not (json.data is Array):
		bridge_discovered.emit(false, "", "Could not parse bridge discovery response.")
		return

	var arr: Array = json.data as Array
	if arr.is_empty():
		bridge_discovered.emit(false, "", "No Philips Hue bridges found on this network.")
		return

	var first: Dictionary = arr[0] as Dictionary
	var found_ip: String = first.get("internalipaddress", "")
	if not found_ip.is_empty():
		bridge_ip = found_ip
		bridge_discovered.emit(true, found_ip, "Found Philips Hue Bridge at " + found_ip)
	else:
		bridge_discovered.emit(false, "", "Bridge entry did not contain an internal IP address.")

func start_pairing(target_ip: String = "") -> void:
	if not target_ip.is_empty():
		bridge_ip = target_ip.strip_edges().trim_prefix("http://").trim_prefix("https://").trim_suffix("/")

	if bridge_ip.is_empty():
		pairing_completed.emit(false, "", "Please enter or discover a Philips Hue Bridge IP address first.")
		return

	_is_pairing = true
	_pair_seconds_left = 30
	pairing_status_changed.emit("Press the round Link Button on your Hue Bridge now...", true, _pair_seconds_left)
	_pair_timer.start()
	_poll_pair_request()

func stop_pairing() -> void:
	_is_pairing = false
	_pair_timer.stop()
	if _http_pair.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_http_pair.cancel_request()
	pairing_status_changed.emit("Pairing cancelled.", false, 0)

func _on_pair_poll_tick() -> void:
	if not _is_pairing:
		return

	_pair_seconds_left -= 1
	if _pair_seconds_left <= 0:
		stop_pairing()
		pairing_completed.emit(false, "", "Pairing timed out. The link button was not pressed in time.")
		return

	pairing_status_changed.emit("Press the round Link Button on your Hue Bridge (%ds left)..." % _pair_seconds_left, true, _pair_seconds_left)
	_poll_pair_request()

func _poll_pair_request() -> void:
	if _http_pair.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return

	var url: String = "http://" + bridge_ip + "/api"
	var payload: Dictionary = {
		"devicetype": "3d_soundscape_studio#desktop"
	}
	var headers: PackedStringArray = ["Content-Type: application/json"]
	_http_pair.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))

func _on_pair_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if not _is_pairing:
		return

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return

	var json: JSON = JSON.new()
	if json.parse(body.get_string_from_utf8()) == OK and json.data is Array:
		var arr: Array = json.data as Array
		for item: Dictionary in arr:
			if item.has("success"):
				var succ: Dictionary = item["success"] as Dictionary
				var new_user: String = succ.get("username", "")
				if not new_user.is_empty():
					username = new_user
					stop_pairing()
					pairing_completed.emit(true, new_user, "Successfully paired with Philips Hue Bridge!")
					fetch_lights()
					return

func fetch_lights() -> void:
	if bridge_ip.is_empty() or username.is_empty():
		error_occurred.emit("Bridge IP and Username are required to fetch lights.")
		return

	if _http_fetch.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_http_fetch.cancel_request()

	var url: String = "http://" + bridge_ip + "/api/" + username + "/lights"
	var err: Error = _http_fetch.request(url)
	if err != OK:
		error_occurred.emit("Failed to send lights fetch request.")

func _on_fetch_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		error_occurred.emit("Fetching lights failed with response code %d." % response_code)
		return

	var json: JSON = JSON.new()
	if json.parse(body.get_string_from_utf8()) == OK and json.data is Dictionary:
		var dict: Dictionary = json.data as Dictionary
		var parsed_lights: Array[Dictionary] = []

		for light_id in dict.keys():
			var l_data: Dictionary = dict[light_id] as Dictionary
			var state: Dictionary = l_data.get("state", {})
			parsed_lights.append({
				"entity_id": str(light_id),
				"name": l_data.get("name", "Hue Light " + str(light_id)),
				"type": l_data.get("type", "Light"),
				"is_on": state.get("on", false),
				"brightness": state.get("bri", 254)
			})

		lights_fetched.emit(parsed_lights)
	else:
		error_occurred.emit("Failed to parse Hue lights response.")

func turn_on_light(light_id: String, rgb: Color, brightness_pct: int, transition_time_sec: float = 0.4) -> void:
	if bridge_ip.is_empty() or username.is_empty() or light_id.is_empty():
		return

	var xy: Vector2 = rgb_to_xy(rgb)
	var bri_val: int = clamp(int(float(brightness_pct) * 2.54), 1, 254)
	var trans_val: int = max(0, int(round(transition_time_sec * 10.0)))

	var payload: Dictionary = {
		"on": true,
		"bri": bri_val,
		"xy": [xy.x, xy.y],
		"transitiontime": trans_val
	}

	_send_light_command(light_id, payload)

func turn_off_light(light_id: String, transition_time_sec: float = 0.4) -> void:
	if bridge_ip.is_empty() or username.is_empty() or light_id.is_empty():
		return

	var trans_val: int = max(0, int(round(transition_time_sec * 10.0)))
	var payload: Dictionary = {
		"on": false,
		"transitiontime": trans_val
	}

	_send_light_command(light_id, payload)

func trigger_lightning_flash(light_id: String, flash_color: Color, restore_color: Color, restore_bri: int, duration_ms: int = 150) -> void:
	if bridge_ip.is_empty() or username.is_empty() or light_id.is_empty():
		return

	# High-velocity flash: transitiontime = 0
	var flash_xy: Vector2 = rgb_to_xy(flash_color)
	var flash_payload: Dictionary = {
		"on": true,
		"bri": 254,
		"xy": [flash_xy.x, flash_xy.y],
		"transitiontime": 0
	}
	_send_light_command(light_id, flash_payload)

	# Restore previous state after duration
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree:
		var delay_sec: float = float(duration_ms) / 1000.0
		tree.create_timer(delay_sec).timeout.connect(func():
			turn_on_light(light_id, restore_color, restore_bri, 0.3)
		)

func _send_light_command(light_id: String, payload: Dictionary) -> void:
	var url: String = "http://" + bridge_ip + "/api/" + username + "/lights/" + light_id + "/state"
	var headers: PackedStringArray = ["Content-Type: application/json"]
	var client: HTTPRequest = HTTPRequest.new()
	client.timeout = 2.0
	client.request_completed.connect(func(_res: int, _code: int, _h: PackedStringArray, _b: PackedByteArray):
		client.queue_free()
	)
	add_child(client)
	client.request(url, headers, HTTPClient.METHOD_PUT, JSON.stringify(payload))

func _on_cmd_completed(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	pass

# Accurate CIE 1931 xy Chromaticity Calculation from sRGB Color for Philips Hue
static func rgb_to_xy(c: Color) -> Vector2:
	var r: float = pow((c.r + 0.055) / 1.055, 2.4) if c.r > 0.04045 else (c.r / 12.92)
	var g: float = pow((c.g + 0.055) / 1.055, 2.4) if c.g > 0.04045 else (c.g / 12.92)
	var b: float = pow((c.b + 0.055) / 1.055, 2.4) if c.b > 0.04045 else (c.b / 12.92)

	# Wide Gamut D65 transformation matrix
	var X: float = r * 0.664511 + g * 0.154324 + b * 0.162028
	var Y: float = r * 0.283881 + g * 0.668433 + b * 0.047685
	var Z: float = r * 0.000088 + g * 0.072310 + b * 0.986039

	var sum: float = X + Y + Z
	if sum <= 0.00001:
		return Vector2(0.3127, 0.3290) # Standard D65 whitepoint

	return Vector2(X / sum, Y / sum)
