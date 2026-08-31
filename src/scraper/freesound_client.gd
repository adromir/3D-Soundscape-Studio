class_name FreesoundClient
extends Node

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio


signal search_started()
signal search_completed(results: Array[Dictionary], total_count: int)
signal search_failed(error_msg: String)

signal download_progress(sound_id: int, percent: float)
signal download_completed(sound_id: int, file_path: String, metadata: Dictionary)
signal download_failed(sound_id: int, error_msg: String)

const BASE_URL = "https://freesound.org/apiv2"
const DEFAULT_API_KEY = "anonymous_preview_token"

var _http_search: HTTPRequest = null
var _http_download: HTTPRequest = null
var _current_downloading_sound: Dictionary = {}

var _preview_callbacks: Dictionary = {} # url -> Array[Callable]
var _preview_cache: Dictionary = {} # url -> AudioStream

func _ready() -> void:
	_http_search = HTTPRequest.new()
	_http_search.name = "SearchHTTPRequest"
	_http_search.timeout = 15.0
	add_child(_http_search)
	_http_search.request_completed.connect(_on_search_request_completed)

	_http_download = HTTPRequest.new()
	_http_download.name = "DownloadHTTPRequest"
	_http_download.timeout = 30.0
	add_child(_http_download)
	_http_download.request_completed.connect(_on_download_request_completed)

func get_api_key() -> String:
	var settings_file: String = AppPaths.get_settings_file()
	if FileAccess.file_exists(settings_file):
		var f: FileAccess = FileAccess.open(settings_file, FileAccess.READ)
		if f:
			var json: JSON = JSON.new()
			if json.parse(f.get_as_text()) == OK and json.data is Dictionary:
				var key: String = json.data.get("freesound_api_key", "").strip_edges()
				if not key.is_empty():
					f.close()
					return key
			f.close()
	return ""

func set_api_key(key: String) -> void:
	var settings_file: String = AppPaths.get_settings_file()
	var data: Dictionary = {}
	if FileAccess.file_exists(settings_file):
		var f: FileAccess = FileAccess.open(settings_file, FileAccess.READ)
		if f:
			var json: JSON = JSON.new()
			if json.parse(f.get_as_text()) == OK and json.data is Dictionary:
				data = json.data
			f.close()
	data["freesound_api_key"] = key.strip_edges()
	var fw: FileAccess = FileAccess.open(settings_file, FileAccess.WRITE)
	if fw:
		fw.store_string(JSON.stringify(data, "\t"))
		fw.close()

func search_sounds(query: String, license_filter: String = "cc0", min_dur: float = 0.0, max_dur: float = 120.0, page: int = 1) -> void:
	if _http_search.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_http_search.cancel_request()

	var api_key: String = get_api_key()
	if api_key.is_empty():
		search_failed.emit("API_KEY_REQUIRED")
		return

	search_started.emit()

	var filter_parts: Array[String] = []

	if license_filter == "cc0":
		filter_parts.append('license:"Creative Commons 0"')
	elif license_filter == "attribution":
		filter_parts.append('license:"Attribution"')

	if max_dur > 0.0:
		filter_parts.append("duration:[%.1f TO %.1f]" % [min_dur, max_dur])

	var filter_str: String = ""
	for i in range(filter_parts.size()):
		if i > 0:
			filter_str += " "
		filter_str += filter_parts[i]

	var fields: String = "id,name,tags,description,license,duration,filesize,previews,images,username,avg_rating,num_downloads"
	var url: String = "%s/search/text/?query=%s&fields=%s&page=%d&page_size=24&token=%s" % [
		BASE_URL,
		query.uri_encode(),
		fields.uri_encode(),
		page,
		api_key
	]

	if not filter_str.is_empty():
		url += "&filter=" + filter_str.uri_encode()

	var headers: PackedStringArray = [
		"User-Agent: 3D-Soundscape-Studio/1.2.0 (Godot4; OpenSourceAudioTools)"
	]

	var err: Error = _http_search.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		search_failed.emit("Failed to dispatch HTTP search request: %d" % err)

func _on_search_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		search_failed.emit("Network connection error: %d" % result)
		return

	if response_code == 401 or response_code == 403:
		search_failed.emit("API_KEY_REQUIRED")
		return

	if response_code != 200:
		var err_text: String = body.get_string_from_utf8()
		search_failed.emit("Freesound API returned code %d: %s" % [response_code, err_text])
		return

	var json_str: String = body.get_string_from_utf8()
	var json: JSON = JSON.new()
	if json.parse(json_str) != OK or not (json.data is Dictionary):
		search_failed.emit("Failed to parse Freesound JSON response.")
		return

	var data: Dictionary = json.data
	var count: int = data.get("count", 0)
	var raw_results: Array = data.get("results", [])

	var parsed_results: Array[Dictionary] = []
	for item in raw_results:
		if item is Dictionary:
			var previews: Dictionary = item.get("previews", {})
			var preview_url: String = previews.get("preview-hq-mp3", previews.get("preview-lq-mp3", previews.get("preview-hq-ogg", "")))
			var images: Dictionary = item.get("images", {})
			var spectral_url: String = images.get("spectral_m", images.get("spectral_l", ""))

			var sound_dict: Dictionary = {
				"id": item.get("id", 0),
				"name": item.get("name", "Untitled Sound"),
				"username": item.get("username", "Unknown Author"),
				"duration": item.get("duration", 0.0),
				"license": item.get("license", "CC0"),
				"tags": item.get("tags", []),
				"description": item.get("description", ""),
				"rating": item.get("avg_rating", 0.0),
				"downloads": item.get("num_downloads", 0),
				"preview_url": preview_url,
				"spectral_url": spectral_url
			}
			parsed_results.append(sound_dict)

	search_completed.emit(parsed_results, count)

func fetch_preview_stream(preview_url: String, callback: Callable) -> void:
	if preview_url.is_empty():
		callback.call(null)
		return

	if _preview_cache.has(preview_url):
		callback.call(_preview_cache[preview_url])
		return

	if _preview_callbacks.has(preview_url):
		_preview_callbacks[preview_url].append(callback)
		return

	_preview_callbacks[preview_url] = [callback]

	var http: HTTPRequest = HTTPRequest.new()
	http.timeout = 20.0
	add_child(http)
	http.request_completed.connect(func(res: int, code: int, _h: PackedStringArray, body: PackedByteArray):
		http.queue_free()
		var stream: AudioStream = null
		if res == HTTPRequest.RESULT_SUCCESS and code == 200 and not body.is_empty():
			if preview_url.ends_with(".ogg"):
				stream = AudioStreamOggVorbis.load_from_buffer(body)
			else:
				var mp3: AudioStreamMP3 = AudioStreamMP3.new()
				mp3.data = body
				stream = mp3

		if stream:
			_preview_cache[preview_url] = stream

		var cbs = _preview_callbacks.get(preview_url, [])
		_preview_callbacks.erase(preview_url)
		for cb in cbs:
			if cb.is_valid():
				cb.call(stream)
	)

	var headers: PackedStringArray = ["User-Agent: 3D-Soundscape-Studio/1.2.0"]
	var err: Error = http.request(preview_url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		_preview_callbacks.erase(preview_url)
		if callback.is_valid():
			callback.call(null)

func download_sound(sound: Dictionary, target_category: String = "Custom") -> void:
	if _http_download.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_http_download.cancel_request()

	_current_downloading_sound = sound.duplicate()
	_current_downloading_sound["target_category"] = target_category

	var preview_url: String = sound.get("preview_url", "")
	if preview_url.is_empty():
		download_failed.emit(sound.get("id", 0), "No valid download or preview stream URL available.")
		return

	var headers: PackedStringArray = [
		"User-Agent: 3D-Soundscape-Studio/1.2.0"
	]

	var err: Error = _http_download.request(preview_url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		download_failed.emit(sound.get("id", 0), "Failed to start sound download: %d" % err)

func _on_download_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var sound_id: int = _current_downloading_sound.get("id", 0)

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		download_failed.emit(sound_id, "Download failed with HTTP status %d" % response_code)
		return

	var cat: String = _current_downloading_sound.get("target_category", "Custom")
	var s_name: String = _current_downloading_sound.get("name", "sound_%d" % sound_id)

	# Clean filename
	var clean_name: String = ""
	for c in s_name:
		if c in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_- ":
			clean_name += c
	clean_name = clean_name.strip_edges()
	if clean_name.is_empty():
		clean_name = "freesound_%d" % sound_id

	var ext: String = ".mp3"
	var preview_url: String = _current_downloading_sound.get("preview_url", "")
	if preview_url.ends_with(".ogg"):
		ext = ".ogg"

	var dest_dir: String = AppPaths.get_default_samples_dir() + "/" + cat
	if not DirAccess.dir_exists_absolute(dest_dir):
		DirAccess.make_dir_recursive_absolute(dest_dir)

	var target_file_path: String = dest_dir + "/" + clean_name + ext
	var f: FileAccess = FileAccess.open(target_file_path, FileAccess.WRITE)
	if f == null:
		download_failed.emit(sound_id, "Failed to write downloaded sample to disk: %s" % target_file_path)
		return

	f.store_buffer(body)
	f.close()

	# Generate metadata JSON
	var meta: Dictionary = {
		"id": sound_id,
		"name": s_name,
		"author": _current_downloading_sound.get("username", "Unknown"),
		"license": _current_downloading_sound.get("license", "CC0"),
		"duration": _current_downloading_sound.get("duration", 0.0),
		"tags": _current_downloading_sound.get("tags", []),
		"source": "https://freesound.org/people/%s/sounds/%d/" % [_current_downloading_sound.get("username", ""), sound_id],
		"imported_at": Time.get_datetime_string_from_system()
	}

	var meta_path: String = dest_dir + "/" + clean_name + ".json"
	var fm: FileAccess = FileAccess.open(meta_path, FileAccess.WRITE)
	if fm:
		fm.store_string(JSON.stringify(meta, "\t"))
		fm.close()

	download_completed.emit(sound_id, target_file_path, meta)
