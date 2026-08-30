class_name AmbientMixerClient
extends Node

# Author: Adromir
# Repository: https://github.com/adromir

const AppPaths = preload("res://src/core/app_paths.gd")

signal progress_changed(current: int, total: int, status_text: String)
signal download_completed(project_path: String, project: SoundscapeData.SoundscapeProject)
signal download_failed(error_message: String)

var _http_request: HTTPRequest = null
var _download_queue: Array[Dictionary] = [] # [{url: String, path: String, is_cover: bool}]
var _current_download_idx: int = 0
var _total_downloads: int = 0

var _mix_title: String = ""
var _mix_description: String = ""
var _mix_image_url: String = ""
var _template_id: String = ""
var _target_folder: String = ""
var _project: SoundscapeData.SoundscapeProject = null
var _audio_mapping: Dictionary = {} # url -> relative local path

func _ready() -> void:
	_http_request = HTTPRequest.new()
	_http_request.timeout = 30.0
	add_child(_http_request)

static func sanitize_filename(raw_name: String) -> String:
	var regex: RegEx = RegEx.new()
	regex.compile("[\\\\/:*?\"<>|\\s]+")
	var clean: String = regex.sub(raw_name.strip_edges(), "_", true)
	if clean.is_empty():
		clean = "untitled_mix"
	return clean.to_lower()

func start_import_from_url(input_url: String) -> void:
	_download_queue.clear()
	_audio_mapping.clear()
	_current_download_idx = 0
	_total_downloads = 0
	_project = SoundscapeData.SoundscapeProject.new()

	input_url = input_url.strip_edges()
	if input_url.is_empty():
		download_failed.emit("URL cannot be empty.")
		return

	# Direct template ID check
	if input_url.is_valid_int():
		_template_id = input_url
		_fetch_xml_template(_template_id)
		return

	if input_url.contains("id_template="):
		var parts: PackedStringArray = input_url.split("id_template=")
		_template_id = parts[1].split("&")[0]
		_fetch_xml_template(_template_id)
		return

	# Fetch HTML page
	progress_changed.emit(0, 100, "Fetching page details...")
	_http_request.request_completed.connect(_on_html_page_received, CONNECT_ONE_SHOT)
	var err: Error = _http_request.request(input_url, ["User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)"])
	if err != OK:
		download_failed.emit("Failed to initiate HTTP request: %d" % err)

func _on_html_page_received(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		download_failed.emit("Failed to fetch webpage (HTTP %d)" % response_code)
		return

	var html: String = body.get_string_from_utf8()

	# Extract Template ID: AmbientMixer.setup(12345);
	var regex_setup: RegEx = RegEx.new()
	regex_setup.compile("AmbientMixer\\.setup\\(([0-9]+)\\);")
	var match_setup: RegExMatch = regex_setup.search(html)

	if match_setup != null:
		_template_id = match_setup.get_string(1)
	else:
		download_failed.emit("Could not find template ID on the page.")
		return

	# Extract Title (h1 or title)
	var regex_h1: RegEx = RegEx.new()
	regex_h1.compile("(?i)<h1[^>]*>(.*?)</h1>")
	var match_h1: RegExMatch = regex_h1.search(html)
	if match_h1 != null:
		_mix_title = match_h1.get_string(1).strip_edges().xml_unescape()
	else:
		var regex_title: RegEx = RegEx.new()
		regex_title.compile("(?i)<title>(.*?)</title>")
		var match_title: RegExMatch = regex_title.search(html)
		if match_title != null:
			var raw_title: String = match_title.get_string(1).strip_edges().xml_unescape()
			_mix_title = raw_title.split(" - Ambient Mixer")[0].strip_edges()
		else:
			_mix_title = "Mix " + _template_id

	# Extract Description (og:description)
	var regex_desc: RegEx = RegEx.new()
	regex_desc.compile("(?i)<meta\\s+property=[\"']og:description[\"']\\s+content=[\"'](.*?)[\"']")
	var match_desc: RegExMatch = regex_desc.search(html)
	if match_desc != null:
		_mix_description = match_desc.get_string(1).strip_edges().xml_unescape()
	else:
		_mix_description = ""

	# Extract Image URL (og:image / twitter:image / direct ambient-mixer image)
	var regex_img: RegEx = RegEx.new()
	regex_img.compile("(?i)<meta\\s+(?:property|name)=[\"'](?:og:image|twitter:image)[\"']\\s+content=[\"'](.*?)[\"']")
	var match_img: RegExMatch = regex_img.search(html)
	if match_img == null:
		var regex_img_rev: RegEx = RegEx.new()
		regex_img_rev.compile("(?i)<meta\\s+content=[\"'](.*?)[\"']\\s+(?:property|name)=[\"'](?:og:image|twitter:image)[\"']")
		match_img = regex_img_rev.search(html)

	if match_img == null:
		var regex_img_direct: RegEx = RegEx.new()
		regex_img_direct.compile("(?i)((?:https?:)?//images\\.ambient-mixer\\.com/images_template/[a-zA-Z0-9_\\-\\.]+\\.(?:jpg|jpeg|png|webp))")
		match_img = regex_img_direct.search(html)

	if match_img != null:
		_mix_image_url = match_img.get_string(1).strip_edges()
		if _mix_image_url.begins_with("//"):
			_mix_image_url = "https:" + _mix_image_url
		elif _mix_image_url.begins_with("/"):
			_mix_image_url = "https://www.ambient-mixer.com" + _mix_image_url
	else:
		_mix_image_url = ""

	_fetch_xml_template(_template_id)

func _fetch_xml_template(template_id: String) -> void:
	progress_changed.emit(10, 100, "Fetching audio configuration template...")
	var xml_url: String = "http://xml.ambient-mixer.com/audio-template?player=html5&id_template=" + template_id
	_http_request.request_completed.connect(_on_xml_template_received, CONNECT_ONE_SHOT)
	var err: Error = _http_request.request(xml_url, ["User-Agent: Mozilla/5.0"])
	if err != OK:
		download_failed.emit("Failed to fetch XML template: %d" % err)

func _on_xml_template_received(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		download_failed.emit("Failed to download audio XML template (HTTP %d)" % response_code)
		return

	var xml_content: String = body.get_string_from_utf8()
	_parse_xml_and_prepare_downloads(xml_content)

func _parse_xml_and_prepare_downloads(xml_content: String) -> void:
	if _mix_title.is_empty():
		_mix_title = "Mix " + _template_id

	var slug: String = sanitize_filename(_mix_title)
	_target_folder = AppPaths.get_default_library_dir().path_join(slug)
	DirAccess.make_dir_recursive_absolute(_target_folder.path_join("audio"))

	# Save raw XML archive
	var xml_backup_path: String = _target_folder.path_join("raw_template.xml")
	var f_xml: FileAccess = FileAccess.open(xml_backup_path, FileAccess.WRITE)
	if f_xml != null:
		f_xml.store_string(xml_content)
		f_xml.close()

	# If project already exists, create a backup to preserve prior user work
	var existing_ambmix: String = _target_folder.path_join("project.ambmix")
	if FileAccess.file_exists(existing_ambmix):
		var bak_path: String = _target_folder.path_join("project.ambmix.bak")
		DirAccess.copy_absolute(existing_ambmix, bak_path)

	_project.title = _mix_title
	_project.description = _mix_description
	_project.author = "AmbientMixer"

	# Parse XML Channels
	var parser: XMLParser = XMLParser.new()
	var err: Error = parser.open_buffer(xml_content.to_utf8_buffer())
	if err != OK:
		download_failed.emit("Failed to parse XML template.")
		return

	var current_channel: int = 0
	var channel_data: Dictionary = {}

	while parser.read() == OK:
		var node_type: XMLParser.NodeType = parser.get_node_type()
		var node_name: String = parser.get_node_name().to_lower()

		if node_type == XMLParser.NODE_ELEMENT:
			if node_name.begins_with("channel"):
				var ch_num_str: String = node_name.replace("channel", "")
				if ch_num_str.is_valid_int():
					current_channel = ch_num_str.to_int()
					channel_data[current_channel] = {}
			elif current_channel > 0:
				var el_name: String = node_name
				if parser.read() == OK and parser.get_node_type() == XMLParser.NODE_TEXT:
					channel_data[current_channel][el_name] = parser.get_node_data().strip_edges()

	# Process parsed channel items
	for ch_idx: int in channel_data.keys():
		var ch_info: Dictionary = channel_data[ch_idx]
		var audio_url: String = ch_info.get("url_audio", "")
		var audio_name: String = ch_info.get("name_audio", "Stem %d" % ch_idx)
		
		# Volume (0-100)
		var vol_str: String = ch_info.get("volume", ch_info.get("volume_audio", "100"))
		# Balance (-100 to +100)
		var pan_str: String = ch_info.get("balance", ch_info.get("balance_audio", "0"))
		# Mute
		var mute_str: String = ch_info.get("mute", "false").to_lower()
		# Random playback
		var rand_str: String = ch_info.get("random", ch_info.get("is_random", "false")).to_lower()
		# Random counter (count per window)
		var rand_counter_str: String = ch_info.get("random_counter", ch_info.get("random_times", "1"))
		# Random unit ("1m", "5m", "10m", "1h")
		var rand_unit_str: String = ch_info.get("random_unit", ch_info.get("random_time", "1m"))
		# Crossfade
		var crossfade_str: String = ch_info.get("crossfade", "false").to_lower()

		if audio_url.is_empty():
			continue

		var ext: String = audio_url.get_extension()
		if ext.is_empty():
			ext = "mp3"

		var safe_stem_name: String = sanitize_filename(audio_name) + "." + ext
		var local_stem_path: String = _target_folder + "/audio/" + safe_stem_name

		_download_queue.append({
			"url": audio_url,
			"path": local_stem_path,
			"is_cover": false
		})

		var track: SoundscapeData.TrackConfig = SoundscapeData.TrackConfig.new()
		track.id = "track_%d" % ch_idx
		track.name = audio_name
		track.file_path = local_stem_path
		track.volume = clampf(float(vol_str) / 100.0, 0.0, 2.0)
		track.muted = (mute_str == "true" or mute_str == "1")
		
		# Balance: -100 (Left) to 100 (Right) -> Map to Azimuth -90 to 90
		var balance_val: float = float(pan_str)
		track.azimuth = clampf((balance_val / 100.0) * 90.0, -180.0, 180.0)
		track.distance = 2.0
		track.channel_mode = SoundscapeData.ChannelRoutingMode.POINT_3D
		track.crossfade = (crossfade_str == "true" or crossfade_str == "1")

		# Trigger & Randomness configuration from XML
		var is_random: bool = (rand_str == "true" or rand_str == "1")
		if is_random:
			track.trigger.mode = SoundscapeData.TriggerMode.RANDOM_INTERVAL
			var counter_val: int = rand_counter_str.to_int()
			if counter_val <= 0: counter_val = 1
			track.trigger.set_from_rate_unit(counter_val, rand_unit_str)
			track.trigger.cooldown_sec = 2.0
		else:
			track.trigger.mode = SoundscapeData.TriggerMode.CONTINUOUS_LOOP

		# Pick an appropriate icon based on stem name
		var lower_name: String = audio_name.to_lower()
		if lower_name.contains("rain") or lower_name.contains("storm") or lower_name.contains("thunder"):
			track.icon_name = "rain"
			track.color_hex = "#00e5ff"
		elif lower_name.contains("fire") or lower_name.contains("burn") or lower_name.contains("flame"):
			track.icon_name = "fire"
			track.color_hex = "#ff9100"
		elif lower_name.contains("wind") or lower_name.contains("breeze") or lower_name.contains("gust"):
			track.icon_name = "wind"
			track.color_hex = "#00e676"
		elif lower_name.contains("bird") or lower_name.contains("owl") or lower_name.contains("crow"):
			track.icon_name = "birds"
			track.color_hex = "#ffd600"
		elif lower_name.contains("water") or lower_name.contains("river") or lower_name.contains("ocean") or lower_name.contains("sea") or lower_name.contains("stream") or lower_name.contains("pour"):
			track.icon_name = "water"
			track.color_hex = "#2979ff"
		elif lower_name.contains("step") or lower_name.contains("walk") or lower_name.contains("foot"):
			track.icon_name = "steps"
			track.color_hex = "#d500f9"
		elif lower_name.contains("bell") or lower_name.contains("chime") or lower_name.contains("clock"):
			track.icon_name = "bell"
			track.color_hex = "#f50057"
		elif lower_name.contains("voice") or lower_name.contains("chant") or lower_name.contains("snor") or lower_name.contains("cough") or lower_name.contains("whisper") or lower_name.contains("people"):
			track.icon_name = "voice"
			track.color_hex = "#ff1744"
		elif lower_name.contains("music") or lower_name.contains("piano") or lower_name.contains("lute") or lower_name.contains("guitar"):
			track.icon_name = "music"
			track.color_hex = "#d500f9"

		_project.tracks.append(track)

	# Cover image download
	if not _mix_image_url.is_empty():
		var cover_path: String = _target_folder + "/cover.jpg"
		_download_queue.append({
			"url": _mix_image_url,
			"path": cover_path,
			"is_cover": true
		})
		_project.cover_image_path = cover_path

	_total_downloads = _download_queue.size()
	if _total_downloads == 0:
		download_failed.emit("No audio tracks found in template.")
		return

	_current_download_idx = 0
	_download_next_file()

func _download_next_file() -> void:
	if _current_download_idx >= _total_downloads:
		_finish_import()
		return

	var item: Dictionary = _download_queue[_current_download_idx]
	var item_url: String = item["url"]
	var item_path: String = item["path"]

	var progress_pct: int = int((float(_current_download_idx) / float(_total_downloads)) * 80.0) + 15
	progress_changed.emit(progress_pct, 100, "Downloading file %d of %d: %s" % [_current_download_idx + 1, _total_downloads, item_path.get_file()])

	_http_request.request_completed.connect(_on_file_downloaded, CONNECT_ONE_SHOT)
	_http_request.download_file = ProjectSettings.globalize_path(item_path)
	var err: Error = _http_request.request(item_url, ["User-Agent: Mozilla/5.0"])
	if err != OK:
		printerr("Download request failed for: ", item_url)
		# Advance anyway to not block entire batch
		_current_download_idx += 1
		_download_next_file()

func _on_file_downloaded(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	_http_request.download_file = "" # Reset download target

	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		printerr("Failed to download item: ", response_code)

	_current_download_idx += 1
	_download_next_file()

func _finish_import() -> void:
	progress_changed.emit(100, 100, "Finalizing project...")
	var project_file_path: String = _target_folder + "/project.ambmix"
	_project.save_to_file(project_file_path)

	# Save metadata.json
	var metadata_path: String = _target_folder + "/metadata.json"
	var meta_file: FileAccess = FileAccess.open(ProjectSettings.globalize_path(metadata_path), FileAccess.WRITE)
	if meta_file != null:
		var meta_dict: Dictionary = {
			"title": _project.title,
			"description": _project.description,
			"author": _project.author,
			"template_id": _template_id,
			"cover": _project.cover_image_path,
			"created_at": Time.get_datetime_string_from_system()
		}
		meta_file.store_string(JSON.stringify(meta_dict, "\t"))
		meta_file.close()

	download_completed.emit(project_file_path, _project)
