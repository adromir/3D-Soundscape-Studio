class_name HomeAssistantClient
extends Node

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

signal connection_tested(success: bool, message: String)
signal light_entities_fetched(entities: Array[Dictionary])
signal service_call_completed(entity_id: String)
signal error_occurred(error_msg: String)

var endpoint: String = "http://homeassistant.local:8123"
var access_token: String = ""

var _http_test: HTTPRequest = null
var _http_fetch: HTTPRequest = null
var _http_command: HTTPRequest = null

func _ready() -> void:
	_http_test = HTTPRequest.new()
	_http_test.name = "TestHTTPRequest"
	_http_test.timeout = 6.0
	add_child(_http_test)
	_http_test.request_completed.connect(_on_test_request_completed)

	_http_fetch = HTTPRequest.new()
	_http_fetch.name = "FetchHTTPRequest"
	_http_fetch.timeout = 8.0
	add_child(_http_fetch)
	_http_fetch.request_completed.connect(_on_fetch_request_completed)

	_http_command = HTTPRequest.new()
	_http_command.name = "CommandHTTPRequest"
	_http_command.timeout = 4.0
	add_child(_http_command)

func configure(ha_url: String, token: String) -> void:
	endpoint = ha_url.strip_edges().trim_suffix("/")
	access_token = token.strip_edges()

func _get_headers() -> PackedStringArray:
	var headers: PackedStringArray = [
		"Content-Type: application/json",
		"User-Agent: 3D-Soundscape-Studio/1.2.0"
	]
	if not access_token.is_empty():
		headers.append("Authorization: Bearer " + access_token)
	return headers

func test_connection() -> void:
	if _http_test.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_http_test.cancel_request()

	var url: String = endpoint + "/api/"
	var err: Error = _http_test.request(url, _get_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		connection_tested.emit(false, "Could not initialize HTTP request: %d" % err)

func _on_test_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		var err_str: String = body.get_string_from_utf8()
		connection_tested.emit(false, "Connection failed (HTTP %d): %s" % [response_code, err_str])
	else:
		connection_tested.emit(true, "Home Assistant API connected successfully!")

func fetch_light_entities() -> void:
	if _http_fetch.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_http_fetch.cancel_request()

	var url: String = endpoint + "/api/states"
	var err: Error = _http_fetch.request(url, _get_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		error_occurred.emit("Failed to fetch states: %d" % err)

func _on_fetch_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		error_occurred.emit("Failed to fetch states (HTTP %d)" % response_code)
		return

	var json_str: String = body.get_string_from_utf8()
	var json: JSON = JSON.new()
	if json.parse(json_str) != OK or not (json.data is Array):
		error_occurred.emit("Failed to parse Home Assistant states JSON.")
		return

	var lights: Array[Dictionary] = []
	for state_obj in json.data:
		if state_obj is Dictionary:
			var entity_id: String = state_obj.get("entity_id", "")
			if entity_id.begins_with("light.") or entity_id.begins_with("switch."):
				var attrs: Dictionary = state_obj.get("attributes", {})
				var friendly_name: String = attrs.get("friendly_name", entity_id)
				var state_val: String = state_obj.get("state", "off")
				lights.append({
					"entity_id": entity_id,
					"name": friendly_name,
					"state": state_val,
					"is_light": entity_id.begins_with("light.")
				})

	light_entities_fetched.emit(lights)

func turn_on_light(entity_id: String, rgb: Color, brightness_pct: int, transition_sec: float = 0.5) -> void:
	var payload: Dictionary = {
		"entity_id": entity_id,
		"brightness": clamp(int(brightness_pct * 2.55), 1, 255),
		"rgb_color": [int(rgb.r * 255), int(rgb.g * 255), int(rgb.b * 255)],
		"transition": transition_sec
	}
	_call_service("light", "turn_on", payload)

func turn_off_light(entity_id: String, transition_sec: float = 0.5) -> void:
	var payload: Dictionary = {
		"entity_id": entity_id,
		"transition": transition_sec
	}
	_call_service("light", "turn_off", payload)

func trigger_lightning_flash(entity_id: String, flash_color: Color, baseline_rgb: Color, baseline_pct: int, duration_ms: int = 150) -> void:
	# 1. Instant strobe flash
	var flash_payload: Dictionary = {
		"entity_id": entity_id,
		"brightness": 255,
		"rgb_color": [int(flash_color.r * 255), int(flash_color.g * 255), int(flash_color.b * 255)],
		"transition": 0.05
	}
	_call_service("light", "turn_on", flash_payload)

	# 2. Schedule restore back to baseline
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree:
		var timer: SceneTreeTimer = tree.create_timer(float(duration_ms) / 1000.0)
		timer.timeout.connect(func():
			var restore_payload: Dictionary = {
				"entity_id": entity_id,
				"brightness": clamp(int(baseline_pct * 2.55), 1, 255),
				"rgb_color": [int(baseline_rgb.r * 255), int(baseline_rgb.g * 255), int(baseline_rgb.b * 255)],
				"transition": 0.35
			}
			_call_service("light", "turn_on", restore_payload)
		)

func _call_service(domain: String, service: String, payload: Dictionary) -> void:
	if access_token.is_empty():
		return # Safe no-op in offline/unconfigured environments

	var http: HTTPRequest = HTTPRequest.new()
	http.timeout = 4.0
	add_child(http)
	http.request_completed.connect(func(_res: int, _code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
	)

	var url: String = "%s/api/services/%s/%s" % [endpoint, domain, service]
	var body: String = JSON.stringify(payload)
	var err: Error = http.request(url, _get_headers(), HTTPClient.METHOD_POST, body)
	if err != OK:
		http.queue_free()
