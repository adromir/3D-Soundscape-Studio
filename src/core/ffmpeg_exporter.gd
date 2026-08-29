class_name FfmpegExporter
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir

signal export_progress(percent: float, message: String)
signal export_completed(exit_code: int, output_path: String)
signal export_failed(reason: String)

var _is_running: bool = false
var _cancel_requested: bool = false

static func get_ffmpeg_binary_path() -> String:
	var base_dir: String = OS.get_executable_path().get_base_dir()
	var bin_name: String = "ffmpeg.exe" if OS.get_name() == "Windows" else "ffmpeg"

	# 1. Check next to Godot executable / project root / bin folder
	var paths_to_check: PackedStringArray = [
		base_dir.path_join(bin_name),
		ProjectSettings.globalize_path("res://").path_join(bin_name),
		ProjectSettings.globalize_path("res://bin/").path_join(bin_name),
		bin_name # System PATH
	]

	for p in paths_to_check:
		if FileAccess.file_exists(p):
			return p

	return bin_name

static func check_ffmpeg_status() -> Dictionary:
	var path: String = get_ffmpeg_binary_path()
	var output: Array = []
	var exit_code: int = OS.execute(path, ["-version"], output, true, false)

	if exit_code == 0 and not output.is_empty():
		var full_text: String = str(output[0])
		var first_line: String = full_text.split("\n")[0]
		var has_sofa: bool = full_text.contains("libmysofa") or full_text.contains("sofalizer")
		return {
			"available": true,
			"path": path,
			"version_info": first_line,
			"has_sofa_support": has_sofa
		}

	return {
		"available": false,
		"path": path,
		"version_info": "",
		"has_sofa_support": false
	}

func cancel_export() -> void:
	_cancel_requested = true

func start_offline_render(
	project: SoundscapeData.SoundscapeProject,
	output_path: String,
	duration_seconds: int = 300,
	custom_sofa_path: String = "",
	custom_layout: SpeakerLayouts.LayoutType = SpeakerLayouts.LayoutType.BINAURAL_SOFA
) -> void:
	if project.tracks.is_empty():
		export_failed.emit("No audio tracks in project.")
		return

	var ffmpeg_path: String = get_ffmpeg_binary_path()
	var active_tracks: Array[SoundscapeData.TrackConfig] = []
	for t in project.tracks:
		if not t.muted and FileAccess.file_exists(ProjectSettings.globalize_path(t.file_path)):
			active_tracks.append(t)

	if active_tracks.is_empty():
		export_failed.emit("No valid active audio files found for export.")
		return

	_is_running = true
	_cancel_requested = false

	var sofa_path: String = custom_sofa_path if not custom_sofa_path.is_empty() else project.sofa_path
	var layout: SpeakerLayouts.LayoutType = custom_layout

	# Build FFmpeg command arguments
	var args: PackedStringArray = PackedStringArray()
	var filter_complex: String = ""
	var mix_inputs: String = ""
	var current_stream_index: int = 0

	# 1. Add input files
	for track in active_tracks:
		args.append("-stream_loop")
		args.append("-1")
		args.append("-i")
		args.append(ProjectSettings.globalize_path(track.file_path))

		if not track.impulse_response_path.is_empty() and FileAccess.file_exists(ProjectSettings.globalize_path(track.impulse_response_path)):
			args.append("-i")
			args.append(ProjectSettings.globalize_path(track.impulse_response_path))

	# 2. Build Filter Graph
	for i in range(active_tracks.size()):
		var track: SoundscapeData.TrackConfig = active_tracks[i]
		var process_label: String = "[%d:a]" % current_stream_index
		current_stream_index += 1

		# Reverb (afir)
		if not track.impulse_response_path.is_empty() and FileAccess.file_exists(ProjectSettings.globalize_path(track.impulse_response_path)):
			var ir_label: String = "[%d:a]" % current_stream_index
			var reverb_label: String = "[reverb_%d]" % i
			filter_complex += "%s%safir=dry=10:wet=10%s;" % [process_label, ir_label, reverb_label]
			process_label = reverb_label
			current_stream_index += 1

		# Volume
		var vol_label: String = "[vol_%d]" % i
		var effective_vol: float = track.volume * project.master_volume
		filter_complex += "%svolume=volume=%f%s;" % [process_label, effective_vol, vol_label]
		process_label = vol_label

		# Spatialization based on layout & channel mode
		var spatial_label: String = "[spatial_%d]" % i

		if layout == SpeakerLayouts.LayoutType.BINAURAL_SOFA and not sofa_path.is_empty() and FileAccess.file_exists(ProjectSettings.globalize_path(sofa_path)):
			var pan_label: String = "[pan_%d]" % i
			filter_complex += "%span=stereo|c0=c0|c1=c0%s;" % [process_label, pan_label]
			var safe_sofa: String = ProjectSettings.globalize_path(sofa_path).replace("\\", "/")
			filter_complex += "%ssofalizer=sofa='%s':speakers=FL %f %f|FR %f %f%s;" % [
				pan_label,
				safe_sofa,
				track.azimuth,
				track.elevation,
				track.azimuth,
				track.elevation,
				spatial_label
			]
		elif track.channel_mode == SoundscapeData.ChannelRoutingMode.MULTI_CHANNEL:
			# Discrete Multi-Channel Routing (Direct mapping to physical surround speakers)
			var fl: float = 1.0 if "FL" in track.target_channels else 0.0
			var fr: float = 1.0 if "FR" in track.target_channels else 0.0
			var fc: float = 1.0 if "FC" in track.target_channels else 0.0
			var lfe: float = 1.0 if "LFE" in track.target_channels else 0.0
			var bl: float = 1.0 if "BL" in track.target_channels else 0.0
			var br: float = 1.0 if "BR" in track.target_channels else 0.0
			var sl: float = 1.0 if "SL" in track.target_channels else 0.0
			var sr: float = 1.0 if "SR" in track.target_channels else 0.0

			if layout == SpeakerLayouts.LayoutType.SURROUND_7_1:
				filter_complex += "%span=7.1|c0=%f*c0|c1=%f*c0|c2=%f*c0|c3=%f*c0|c4=%f*c0|c5=%f*c0|c6=%f*c0|c7=%f*c0%s;" % [
					process_label, fl, fr, fc, lfe, bl, br, sl, sr, spatial_label
				]
			elif layout == SpeakerLayouts.LayoutType.SURROUND_5_1:
				filter_complex += "%span=5.1|c0=%f*c0|c1=%f*c0|c2=%f*c0|c3=%f*c0|c4=%f*c0|c5=%f*c0%s;" % [
					process_label, fl, fr, fc, lfe, maxf(bl, sl), maxf(br, sr), spatial_label
				]
			elif layout == SpeakerLayouts.LayoutType.QUADRAPHONIC:
				filter_complex += "%span=quad|c0=%f*c0|c1=%f*c0|c2=%f*c0|c3=%f*c0%s;" % [
					process_label, fl, fr, maxf(bl, sl), maxf(br, sr), spatial_label
				]
			else:
				var l_gain: float = maxf(fl, maxf(bl, sl))
				var r_gain: float = maxf(fr, maxf(br, sr))
				filter_complex += "%span=stereo|c0=%f*c0|c1=%f*c0%s;" % [
					process_label, l_gain, r_gain, spatial_label
				]
		elif track.channel_mode == SoundscapeData.ChannelRoutingMode.OMNIPRESENT:
			# Omnipresent: duplicate equally to stereo or surround channels
			if layout == SpeakerLayouts.LayoutType.SURROUND_5_1:
				filter_complex += "%span=5.1|c0=c0|c1=c0|c2=0.5*c0|c3=0.1*c0|c4=0.8*c0|c5=0.8*c0%s;" % [process_label, spatial_label]
			elif layout == SpeakerLayouts.LayoutType.SURROUND_7_1:
				filter_complex += "%span=7.1|c0=c0|c1=c0|c2=0.5*c0|c3=0.1*c0|c4=0.7*c0|c5=0.7*c0|c6=0.7*c0|c7=0.7*c0%s;" % [process_label, spatial_label]
			elif layout == SpeakerLayouts.LayoutType.QUADRAPHONIC:
				filter_complex += "%span=quad|c0=c0|c1=c0|c2=c0|c3=c0%s;" % [process_label, spatial_label]
			else:
				filter_complex += "%span=stereo|c0=c0|c1=c0%s;" % [process_label, spatial_label]
		else:
			# Standard stereo or surround panning based on azimuth angle
			var az: float = track.azimuth # -180 to 180
			var pan_val: float = clampf((az / 90.0), -1.0, 1.0) # -1.0 (Left) to 1.0 (Right)
			var left_gain: float = clampf((1.0 - pan_val) * 0.5, 0.0, 1.0)
			var right_gain: float = clampf((1.0 + pan_val) * 0.5, 0.0, 1.0)

			if layout == SpeakerLayouts.LayoutType.SURROUND_5_1:
				var rear_factor: float = clampf(absf(az) / 180.0, 0.0, 1.0)
				var front_factor: float = 1.0 - rear_factor
				filter_complex += "%span=5.1|c0=%f*c0|c1=%f*c0|c2=0.2*c0|c3=0|c4=%f*c0|c5=%f*c0%s;" % [
					process_label,
					left_gain * front_factor,
					right_gain * front_factor,
					left_gain * rear_factor,
					right_gain * rear_factor,
					spatial_label
				]
			else:
				filter_complex += "%span=stereo|c0=%f*c0|c1=%f*c0%s;" % [
					process_label,
					left_gain,
					right_gain,
					spatial_label
				]

		mix_inputs += spatial_label

	# 3. Summing and dynamic normalization
	var _final_layout_str: String = SpeakerLayouts.get_ffmpeg_layout_name(layout)
	filter_complex += "%samix=inputs=%d:normalize=0,dynaudnorm[out]" % [mix_inputs, active_tracks.size()]

	args.append("-filter_complex")
	args.append(filter_complex)
	args.append("-map")
	args.append("[out]")
	args.append("-t")
	args.append(str(duration_seconds))
	args.append("-y")
	args.append(ProjectSettings.globalize_path(output_path))

	export_progress.emit(10.0, "Starting offline rendering...")

	# Asynchronous execution in WorkerThreadPool
	WorkerThreadPool.add_task(func():
		var output: Array = []
		var exit_code: int = OS.execute(ffmpeg_path, args, output, true, false)

		_is_running = false
		if exit_code == 0:
			export_progress.emit.call_deferred(100.0, "Export completed successfully.")
			export_completed.emit.call_deferred(exit_code, output_path)
		else:
			var err_msg: String = "FFmpeg export failed with exit code %d.\nDetails: %s" % [exit_code, "\n".join(output)]
			export_failed.emit.call_deferred(err_msg)
	)
