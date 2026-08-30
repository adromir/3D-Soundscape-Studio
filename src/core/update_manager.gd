class_name UpdateManager
extends Node

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

const AppPaths = preload("res://src/core/app_paths.gd")

signal check_completed(has_update: bool, release_info: Dictionary)
signal check_failed(error_message: String)
signal download_progress(downloaded_bytes: int, total_bytes: int, percent: float)
signal download_completed(file_path: String)
signal download_failed(error_message: String)

const DEFAULT_REPO: String = "adromir/3D-Soundscape-Studio"
const API_URL_TEMPLATE: String = "https://api.github.com/repos/%s/releases/latest"

var _check_http: HTTPRequest = null
var _download_http: HTTPRequest = null
var _is_checking: bool = false
var _is_downloading: bool = false
var _download_target_path: String = ""
var _last_release_info: Dictionary = {}
var _progress_timer: Timer = null

func _ready() -> void:
	_check_http = HTTPRequest.new()
	_check_http.name = "CheckHTTPRequest"
	_check_http.timeout = 15.0
	_check_http.request_completed.connect(_on_check_request_completed)
	add_child(_check_http)

	_download_http = HTTPRequest.new()
	_download_http.name = "DownloadHTTPRequest"
	_download_http.timeout = 120.0
	_download_http.request_completed.connect(_on_download_request_completed)
	add_child(_download_http)

	_progress_timer = Timer.new()
	_progress_timer.name = "ProgressTimer"
	_progress_timer.wait_time = 0.1
	_progress_timer.timeout.connect(_on_progress_tick)
	add_child(_progress_timer)

# ==================== VERSION UTILITIES ====================

static func get_current_version() -> String:
	if FileAccess.file_exists("res://version.txt"):
		var f: FileAccess = FileAccess.open("res://version.txt", FileAccess.READ)
		if f:
			var v: String = f.get_as_text().strip_edges()
			if not v.is_empty():
				return v
	var proj_ver: String = str(ProjectSettings.get_setting("application/config/version", ""))
	if not proj_ver.is_empty():
		return proj_ver
	return "v2.0.0"

static func parse_version_numbers(ver_str: String) -> Array[int]:
	var clean: String = ver_str.strip_edges().to_lower()
	if clean.begins_with("v"):
		clean = clean.substr(1)
	
	# Strip pre-release suffixes like -beta, -rc1
	if clean.contains("-"):
		clean = clean.split("-")[0]
	if clean.contains("+"):
		clean = clean.split("+")[0]
		
	var parts: PackedStringArray = clean.split(".")
	var numbers: Array[int] = []
	for part in parts:
		if part.is_valid_int():
			numbers.append(part.to_int())
		else:
			numbers.append(0)
	while numbers.size() < 3:
		numbers.append(0)
	return numbers

static func is_version_newer(latest_ver_str: String, current_ver_str: String) -> bool:
	var latest_nums: Array[int] = parse_version_numbers(latest_ver_str)
	var current_nums: Array[int] = parse_version_numbers(current_ver_str)
	
	for i in range(mini(latest_nums.size(), current_nums.size())):
		if latest_nums[i] > current_nums[i]:
			return true
		elif latest_nums[i] < current_nums[i]:
			return false
	return false

# ==================== CHECK FOR UPDATES ====================

func check_for_updates(repo_slug: String = DEFAULT_REPO) -> void:
	if _is_checking:
		return
	_is_checking = true

	var url: String = API_URL_TEMPLATE % repo_slug
	var headers: PackedStringArray = [
		"User-Agent: 3D-Soundscape-Studio/" + get_current_version(),
		"Accept: application/vnd.github.v3+json"
	]

	var err: Error = _check_http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		_is_checking = false
		check_failed.emit("Failed to initiate update check request: Error code %d" % err)

func _on_check_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_is_checking = false

	if result != HTTPRequest.RESULT_SUCCESS:
		check_failed.emit("Network connection error (HTTP Result: %d)" % result)
		return

	if response_code != 200:
		check_failed.emit("GitHub API returned HTTP %d" % response_code)
		return

	var body_text: String = body.get_string_from_utf8()
	var json: JSON = JSON.new()
	if json.parse(body_text) != OK or not (json.data is Dictionary):
		check_failed.emit("Failed to parse release response from GitHub.")
		return

	var data: Dictionary = json.data as Dictionary
	var tag_name: String = str(data.get("tag_name", ""))
	if tag_name.is_empty():
		tag_name = str(data.get("name", ""))

	var curr_ver: String = get_current_version()
	var has_new: bool = is_version_newer(tag_name, curr_ver)

	var assets_data: Array = data.get("assets", [])
	var processed_assets: Array[Dictionary] = []
	for a in assets_data:
		if a is Dictionary:
			processed_assets.append({
				"name": str(a.get("name", "")),
				"size": int(a.get("size", 0)),
				"download_url": str(a.get("browser_download_url", "")),
				"content_type": str(a.get("content_type", ""))
			})

	_last_release_info = {
		"tag_name": tag_name,
		"title": str(data.get("name", tag_name)),
		"body": str(data.get("body", "")),
		"html_url": str(data.get("html_url", "")),
		"published_at": str(data.get("published_at", "")),
		"assets": processed_assets,
		"current_version": curr_ver,
		"has_update": has_new
	}

	check_completed.emit(has_new, _last_release_info)

# ==================== ASSET RESOLUTION ====================

static func find_best_asset_for_os(assets: Array) -> Dictionary:
	var os_name: String = OS.get_name().to_lower()
	
	# Priority matches based on operating system
	var patterns: Array[String] = []
	if os_name == "windows":
		patterns = ["win64.zip", "windows.zip", "windows-x86_64.zip", "windows", ".exe", ".zip"]
	elif os_name == "linux" or os_name == "x11":
		patterns = ["linux.zip", "x86_64.appimage", ".appimage", "linux", ".tar.gz", ".zip"]
	elif os_name == "macos" or os_name == "osx":
		patterns = ["macos.dmg", "macos.zip", ".dmg", "mac.zip", "macos", ".zip"]
	else:
		patterns = [".zip"]

	for pat in patterns:
		for item in assets:
			if item is Dictionary:
				var a_name: String = str(item.get("name", "")).to_lower()
				if a_name.contains(pat):
					return item

	# Fallback to first available asset
	if not assets.is_empty() and assets[0] is Dictionary:
		return assets[0]
	return {}

# ==================== DOWNLOAD UPDATE ====================

func start_download(asset_url: String, filename: String = "") -> void:
	if _is_downloading:
		return
	if asset_url.is_empty():
		download_failed.emit("Asset download URL is empty.")
		return

	if filename.is_empty():
		filename = asset_url.get_file()
		if filename.is_empty():
			filename = "soundscape_update.zip"

	var updates_dir: String = AppPaths.get_default_updates_dir()
	_download_target_path = updates_dir.path_join(filename)

	# Clean previous partial download
	if FileAccess.file_exists(_download_target_path):
		DirAccess.remove_absolute(_download_target_path)

	_download_http.download_file = _download_target_path
	_is_downloading = true
	_progress_timer.start()

	var headers: PackedStringArray = [
		"User-Agent: 3D-Soundscape-Studio/" + get_current_version(),
		"Accept: application/octet-stream"
	]

	var err: Error = _download_http.request(asset_url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		_is_downloading = false
		_progress_timer.stop()
		download_failed.emit("Failed to initiate download: Error %d" % err)

func _on_progress_tick() -> void:
	if not _is_downloading or _download_http == null:
		return
	var downloaded: int = _download_http.get_downloaded_bytes()
	var total: int = _download_http.get_body_size()
	var pct: float = 0.0
	if total > 0:
		pct = clampf((float(downloaded) / float(total)) * 100.0, 0.0, 100.0)
	download_progress.emit(downloaded, total, pct)

func _on_download_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	_is_downloading = false
	_progress_timer.stop()

	if result != HTTPRequest.RESULT_SUCCESS:
		download_failed.emit("Download failed with HTTP Result: %d" % result)
		return

	if response_code != 200 and response_code != 302 and response_code != 301:
		download_failed.emit("Download failed with HTTP status: %d" % response_code)
		return

	if not FileAccess.file_exists(_download_target_path):
		download_failed.emit("Downloaded update file not found on disk.")
		return

	download_progress.emit(_download_http.get_body_size(), _download_http.get_body_size(), 100.0)
	download_completed.emit(_download_target_path)

# ==================== SELF-UPDATE & RESTART ====================

func apply_update_and_restart(file_path: String) -> Dictionary:
	var global_file: String = ProjectSettings.globalize_path(file_path)
	if not FileAccess.file_exists(global_file):
		return {"success": false, "message": "Update file does not exist: " + global_file}

	if OS.has_feature("editor"):
		return {
			"success": true,
			"is_editor": true,
			"message": "Running inside Godot Editor. Automatic executable replacement is skipped. Update package is saved at:\n" + global_file
		}

	var os_name: String = OS.get_name().to_lower()
	var current_exe: String = OS.get_executable_path()
	var current_pid: int = OS.get_process_id()
	var updates_dir: String = AppPaths.get_default_updates_dir()

	if os_name == "windows":
		var staged_exe: String = ""
		if global_file.to_lower().ends_with(".zip"):
			var staged_dir: String = updates_dir.path_join("staged")
			if DirAccess.dir_exists_absolute(staged_dir):
				_delete_dir_recursive(staged_dir)
			DirAccess.make_dir_recursive_absolute(staged_dir)

			var reader: ZIPReader = ZIPReader.new()
			if reader.open(global_file) == OK:
				var files: PackedStringArray = reader.get_files()
				for f in files:
					if f.ends_with("/"):
						DirAccess.make_dir_recursive_absolute(staged_dir.path_join(f))
						continue
					var f_bytes: PackedByteArray = reader.read_file(f)
					var target_out: String = staged_dir.path_join(f)
					var parent_d: String = target_out.get_base_dir()
					if not DirAccess.dir_exists_absolute(parent_d):
						DirAccess.make_dir_recursive_absolute(parent_d)
					var out_f: FileAccess = FileAccess.open(target_out, FileAccess.WRITE)
					if out_f:
						out_f.store_buffer(f_bytes)
						out_f.close()
					if f.to_lower().ends_with(".exe") and staged_exe.is_empty():
						staged_exe = target_out
				reader.close()
		elif global_file.to_lower().ends_with(".exe"):
			staged_exe = global_file

		if staged_exe.is_empty():
			staged_exe = global_file

		# Generate a reliable PowerShell updater script
		var ps_script: String = updates_dir.path_join("apply_update.ps1")
		var ps_code: String = """
# 3D Soundscape Studio Self-Updater Script
param([int]$ProcessId, [string]$SourcePath, [string]$TargetPath, [string]$StagedFolder)

Start-Sleep -Milliseconds 600
try {
    $proc = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if ($proc) {
        $proc.WaitForExit(8000)
    }
} catch {}

Start-Sleep -Milliseconds 400

try {
    if (Test-Path $StagedFolder) {
        Copy-Item -Path "$StagedFolder\\*" -Destination (Split-Path -Parent $TargetPath) -Recurse -Force -ErrorAction Stop
    } else {
        Copy-Item -Path $SourcePath -Destination $TargetPath -Force -ErrorAction Stop
    }
} catch {
    # Fallback copy
    Copy-Item -Path $SourcePath -Destination $TargetPath -Force -ErrorAction SilentlyContinue
}

Start-Sleep -Milliseconds 200
Start-Process -FilePath $TargetPath
"""
		var sf: FileAccess = FileAccess.open(ps_script, FileAccess.WRITE)
		if sf:
			sf.store_string(ps_code)
			sf.close()

		var staged_folder_arg: String = updates_dir.path_join("staged") if global_file.to_lower().ends_with(".zip") else ""
		var args: PackedStringArray = [
			"-NoProfile",
			"-ExecutionPolicy", "Bypass",
			"-File", ps_script,
			"-ProcessId", str(current_pid),
			"-SourcePath", staged_exe,
			"-TargetPath", current_exe,
			"-StagedFolder", staged_folder_arg
		]

		OS.create_process("powershell.exe", args)
		get_tree().quit(0)
		return {"success": true, "message": "Restarting application..."}

	elif os_name == "linux" or os_name == "x11":
		var sh_script: String = updates_dir.path_join("apply_update.sh")
		var sh_code: String = """#!/bin/bash
PID=$1
SRC="$2"
TARGET="$3"

sleep 0.8
while kill -0 $PID 2>/dev/null; do
    sleep 0.3
done

cp -f "$SRC" "$TARGET"
chmod +x "$TARGET"
"$TARGET" &
"""
		var sf: FileAccess = FileAccess.open(sh_script, FileAccess.WRITE)
		if sf:
			sf.store_string(sh_code)
			sf.close()
		OS.execute("chmod", ["+x", sh_script])
		OS.create_process("/bin/bash", [sh_script, str(current_pid), global_file, current_exe])
		get_tree().quit(0)
		return {"success": true, "message": "Restarting application..."}

	return {
		"success": true,
		"message": "Update downloaded. Please replace your application with: " + global_file
	}

static func _delete_dir_recursive(dir_path: String) -> void:
	if not DirAccess.dir_exists_absolute(dir_path):
		return
	var d: DirAccess = DirAccess.open(dir_path)
	if d:
		d.list_dir_begin()
		var file_name: String = d.get_next()
		while not file_name.is_empty():
			if file_name != "." and file_name != "..":
				var full: String = dir_path.path_join(file_name)
				if d.current_is_dir():
					_delete_dir_recursive(full)
				else:
					DirAccess.remove_absolute(full)
			file_name = d.get_next()
		d.list_dir_end()
		DirAccess.remove_absolute(dir_path)
