class_name DependencyInstaller
extends Node

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

signal progress_changed(status_text: String, percent: float)
signal download_completed(type: String, path: String)
signal download_failed(error_message: String)

var _http_request: HTTPRequest = null
var _current_target_file: String = ""
var _current_type: String = ""

static func get_os_type() -> String:
	var os: String = OS.get_name().to_lower()
	if "windows" in os:
		return "windows"
	elif "macos" in os or "osx" in os:
		return "macos"
	elif "linux" in os or "bsd" in os or "x11" in os:
		return "linux"
	return "unknown"

static func get_arch_type() -> String:
	var arch: String = Engine.get_architecture_name().to_lower()
	if "arm64" in arch or "aarch64" in arch:
		return "arm64"
	return "x86_64"

func _ready() -> void:
	_http_request = HTTPRequest.new()
	_http_request.timeout = 300.0
	_http_request.use_threads = true
	_http_request.request_completed.connect(_on_request_completed)
	add_child(_http_request)

func _process(_delta: float) -> void:
	if _http_request and _http_request.get_http_client_status() == HTTPClient.STATUS_BODY:
		var downloaded: int = _http_request.get_downloaded_bytes()
		var total: int = _http_request.get_body_size()
		if total > 0:
			var pct: float = float(downloaded) / float(total) * 100.0
			var downloaded_mb: float = float(downloaded) / 1048576.0
			var total_mb: float = float(total) / 1048576.0
			var status: String = "Downloading %.1f MB / %.1f MB" % [downloaded_mb, total_mb]
			progress_changed.emit(status, pct)
		else:
			var downloaded_mb: float = float(downloaded) / 1048576.0
			progress_changed.emit("Downloading %.1f MB..." % downloaded_mb, 0.0)

func download_ffmpeg(target_dir: String) -> void:
	_current_type = "ffmpeg"
	
	if not DirAccess.dir_exists_absolute(target_dir):
		DirAccess.make_dir_recursive_absolute(target_dir)
		
	var os_type: String = get_os_type()
	var arch: String = get_arch_type()
	var url: String = ""

	if os_type == "windows":
		url = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
	elif os_type == "macos":
		if arch == "arm64":
			url = "https://ffmpeg.martin-riedl.de/redirect/latest/macos/arm64/snapshot/ffmpeg.zip"
		else:
			url = "https://ffmpeg.martin-riedl.de/redirect/latest/macos/amd64/snapshot/ffmpeg.zip"
	elif os_type == "linux":
		if arch == "arm64":
			url = "https://ffmpeg.martin-riedl.de/redirect/latest/linux/arm64/snapshot/ffmpeg.zip"
		else:
			url = "https://ffmpeg.martin-riedl.de/redirect/latest/linux/amd64/snapshot/ffmpeg.zip"
	else:
		download_failed.emit("Unsupported operating system for automated FFmpeg download: " + OS.get_name())
		return

	var zip_path: String = target_dir.path_join("ffmpeg_tmp.zip")
	_current_target_file = zip_path
	_http_request.download_file = zip_path
	
	progress_changed.emit("Starting FFmpeg download for %s (%s)..." % [OS.get_name(), arch], 0.0)
	var err: int = _http_request.request(url)
	if err != OK:
		download_failed.emit("Failed to initiate FFmpeg download request.")

func download_audiocpp(target_dir: String) -> void:
	_current_type = "audiocpp_api"
	
	if not DirAccess.dir_exists_absolute(target_dir):
		DirAccess.make_dir_recursive_absolute(target_dir)
		
	_current_target_file = target_dir
	_http_request.download_file = "" # Fetch JSON to memory
	
	progress_changed.emit("Fetching latest audio.cpp release from GitHub...", 0.0)
	var url: String = "https://api.github.com/repos/0xShug0/audio.cpp/releases/latest"
	var headers: PackedStringArray = ["User-Agent: 3D-Soundscape-Studio"]
	var err: int = _http_request.request(url, headers)
	if err != OK:
		download_failed.emit("Failed to query audio.cpp releases.")

func download_model(url: String, target_dir: String) -> void:
	_current_type = "gguf_model"
	
	if not DirAccess.dir_exists_absolute(target_dir):
		DirAccess.make_dir_recursive_absolute(target_dir)
		
	var file_name: String = url.get_file()
	if file_name.is_empty() or not file_name.ends_with(".gguf"):
		file_name = "audiogen-medium.q8_0.gguf"
		
	var out_path: String = target_dir.path_join(file_name)
	_current_target_file = out_path
	_http_request.download_file = out_path
	
	progress_changed.emit("Starting Model download...", 0.0)
	var err: int = _http_request.request(url)
	if err != OK:
		download_failed.emit("Failed to initiate Model download request.")

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code >= 400:
		download_failed.emit("Download failed with HTTP response code: " + str(response_code))
		return
		
	if _current_type == "audiocpp_api":
		var json_str: String = body.get_string_from_utf8()
		var parser: JSON = JSON.new()
		if parser.parse(json_str) == OK:
			var data: Dictionary = parser.data as Dictionary
			var assets: Array = data.get("assets", [])
			var download_url: String = ""
			var os_type: String = get_os_type()
			var arch: String = get_arch_type()

			if os_type == "windows":
				for asset: Dictionary in assets:
					var a_name: String = asset.get("name", "").to_lower()
					if "windows" in a_name and "vulkan" in a_name and a_name.ends_with(".zip"):
						download_url = asset.get("browser_download_url", "")
						break
				if download_url.is_empty():
					for asset: Dictionary in assets:
						var a_name: String = asset.get("name", "").to_lower()
						if "windows" in a_name and "cpu" in a_name and not "portable" in a_name and a_name.ends_with(".zip"):
							download_url = asset.get("browser_download_url", "")
							break
			elif os_type == "macos":
				if arch == "arm64":
					for asset: Dictionary in assets:
						var a_name: String = asset.get("name", "").to_lower()
						if "macos" in a_name and "arm64" in a_name:
							download_url = asset.get("browser_download_url", "")
							break
				if download_url.is_empty():
					for asset: Dictionary in assets:
						var a_name: String = asset.get("name", "").to_lower()
						if "macos" in a_name and ("x64" in a_name or "x86_64" in a_name or "intel" in a_name):
							download_url = asset.get("browser_download_url", "")
							break
				if download_url.is_empty():
					for asset: Dictionary in assets:
						var a_name: String = asset.get("name", "").to_lower()
						if "macos" in a_name:
							download_url = asset.get("browser_download_url", "")
							break
			elif os_type == "linux":
				for asset: Dictionary in assets:
					var a_name: String = asset.get("name", "").to_lower()
					if ("ubuntu" in a_name or "linux" in a_name) and "vulkan" in a_name:
						download_url = asset.get("browser_download_url", "")
						break
				if download_url.is_empty():
					for asset: Dictionary in assets:
						var a_name: String = asset.get("name", "").to_lower()
						if ("ubuntu" in a_name or "linux" in a_name) and "cpu" in a_name:
							download_url = asset.get("browser_download_url", "")
							break
				if download_url.is_empty():
					for asset: Dictionary in assets:
						var a_name: String = asset.get("name", "").to_lower()
						if "ubuntu" in a_name or "linux" in a_name:
							download_url = asset.get("browser_download_url", "")
							break

			if not download_url.is_empty():
				var ext: String = ".zip"
				if download_url.ends_with(".tar.gz"):
					ext = ".tar.gz"
				elif download_url.ends_with(".tgz"):
					ext = ".tgz"
				elif download_url.ends_with(".tar.xz"):
					ext = ".tar.xz"
					
				_current_type = "audiocpp_archive"
				var archive_path: String = _current_target_file.path_join("audiocpp_tmp" + ext)
				_current_target_file = archive_path
				_http_request.download_file = archive_path
				progress_changed.emit("Downloading audio.cpp binary for %s..." % OS.get_name(), 0.0)
				_http_request.request(download_url)
				return
			else:
				download_failed.emit("Could not find a compatible audio.cpp release for %s on GitHub." % OS.get_name())
				return
		else:
			download_failed.emit("Failed to parse GitHub API response.")
			return

	elif _current_type == "ffmpeg":
		progress_changed.emit("Extracting FFmpeg...", 100.0)
		_extract_ffmpeg(_current_target_file)
	elif _current_type == "audiocpp_archive":
		progress_changed.emit("Extracting audio.cpp...", 100.0)
		_extract_audiocpp(_current_target_file)
	elif _current_type == "gguf_model":
		download_completed.emit("gguf_model", _current_target_file)

func _extract_ffmpeg(zip_path: String) -> void:
	var target_dir: String = zip_path.get_base_dir()
	var final_exe_path: String = ""
	var os_type: String = get_os_type()
	
	var reader: ZIPReader = ZIPReader.new()
	var err: int = reader.open(zip_path)
	if err == OK:
		for file: String in reader.get_files():
			var f_name: String = file.get_file()
			if f_name == "ffmpeg" or f_name == "ffmpeg.exe" or f_name == "ffprobe" or f_name == "ffprobe.exe":
				var extract_path: String = target_dir.path_join(f_name)
				var data: PackedByteArray = reader.read_file(file)
				var fa: FileAccess = FileAccess.open(extract_path, FileAccess.WRITE)
				if fa:
					fa.store_buffer(data)
					fa.close()
					
					# Mark executable on Linux and macOS
					if os_type != "windows":
						OS.execute("chmod", ["+x", extract_path])
						if os_type == "macos":
							OS.execute("xattr", ["-dr", "com.apple.quarantine", extract_path])
							
					if f_name == "ffmpeg" or f_name == "ffmpeg.exe":
						final_exe_path = extract_path
		reader.close()
		DirAccess.remove_absolute(zip_path)
		
		if final_exe_path.is_empty():
			download_failed.emit("Could not find ffmpeg binary inside the downloaded archive.")
		else:
			download_completed.emit("ffmpeg", final_exe_path)
	else:
		download_failed.emit("Failed to open FFmpeg ZIP archive.")

func _extract_audiocpp(archive_path: String) -> void:
	var target_dir: String = archive_path.get_base_dir()
	var os_type: String = get_os_type()
	var candidates: Array[String] = [
		"audiocpp_cli", "audiocpp_cli.exe",
		"audio", "audio.exe",
		"audiocpp_server", "audiocpp_server.exe",
		"audio.cpp", "audio.cpp.exe"
	]

	if archive_path.ends_with(".zip"):
		var reader: ZIPReader = ZIPReader.new()
		var err: int = reader.open(archive_path)
		if err == OK:
			for file: String in reader.get_files():
				if file.ends_with("/"):
					var dir_to_create: String = target_dir.path_join(file)
					if not DirAccess.dir_exists_absolute(dir_to_create):
						DirAccess.make_dir_recursive_absolute(dir_to_create)
					continue
					
				var extract_path: String = target_dir.path_join(file)
				var parent_d: String = extract_path.get_base_dir()
				if not DirAccess.dir_exists_absolute(parent_d):
					DirAccess.make_dir_recursive_absolute(parent_d)
					
				var data: PackedByteArray = reader.read_file(file)
				var fa: FileAccess = FileAccess.open(extract_path, FileAccess.WRITE)
				if fa:
					fa.store_buffer(data)
					fa.close()
			reader.close()
			DirAccess.remove_absolute(archive_path)
		else:
			DirAccess.remove_absolute(archive_path)
			download_failed.emit("Failed to open audio.cpp ZIP archive.")
			return
	else:
		# tar.gz, tgz, tar.xz: Use system tar on Linux, macOS, and Windows 10+
		var args: PackedStringArray = ["-xf", archive_path, "-C", target_dir]
		var exit_code: int = OS.execute("tar", args)
		DirAccess.remove_absolute(archive_path)
		if exit_code != 0:
			download_failed.emit("Failed to extract audio.cpp tar archive (tar exit code %d)." % exit_code)
			return

	var final_exe_path: String = _find_executable(target_dir, candidates)
	if final_exe_path.is_empty():
		download_failed.emit("Could not find audio.cpp / audiocpp_cli binary in the extracted archive.")
		return

	# Set executable permissions on Linux/macOS
	if os_type != "windows":
		OS.execute("chmod", ["+x", final_exe_path])
		for extra: String in ["audiocpp_cli", "audiocpp_server", "audiocpp_gguf", "audio", "audio.cpp"]:
			var p: String = target_dir.path_join(extra)
			if FileAccess.file_exists(p):
				OS.execute("chmod", ["+x", p])
		if os_type == "macos":
			OS.execute("xattr", ["-dr", "com.apple.quarantine", target_dir])

	download_completed.emit("audiocpp", final_exe_path)

func _find_executable(dir_path: String, candidates: Array[String]) -> String:
	var da: DirAccess = DirAccess.open(dir_path)
	if da:
		da.list_dir_begin()
		var item: String = da.get_next()
		while not item.is_empty():
			if not item.begins_with("."):
				var full_p: String = dir_path.path_join(item)
				if da.current_is_dir():
					var sub_res: String = _find_executable(full_p, candidates)
					if not sub_res.is_empty():
						return sub_res
				else:
					for cand in candidates:
						if item == cand or item.to_lower() == cand.to_lower():
							return full_p
			item = da.get_next()
		da.list_dir_end()
	return ""
