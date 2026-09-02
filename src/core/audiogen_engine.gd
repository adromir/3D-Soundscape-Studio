class_name AudioGenEngine
extends Node

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio


signal generation_started(prompt: String)
signal generation_progress(percent: float)
signal generation_completed(sample_name: String, file_path: String, metadata: Dictionary)
signal generation_failed(error_msg: String)

enum BackendMode {
	PROCEDURAL_DSP,
	AUDIO_CPP_NEURAL
}

var backend: BackendMode = BackendMode.AUDIO_CPP_NEURAL
var is_generating: bool = false
var audio_cpp_binary_path: String = ""
var model_path: String = ""

func _ready() -> void:
	_detect_local_environment()

func _detect_local_environment() -> void:
	var settings_file: String = AppPaths.get_settings_file()
	if FileAccess.file_exists(settings_file):
		var f: FileAccess = FileAccess.open(settings_file, FileAccess.READ)
		if f:
			var json: JSON = JSON.new()
			if json.parse(f.get_as_text()) == OK and json.data is Dictionary:
				audio_cpp_binary_path = json.data.get("audio_cpp_binary_path", "")
				model_path = json.data.get("audio_cpp_model_path", "")
				if int(json.data.get("audiogen_backend", 0)) == 1 and not audio_cpp_binary_path.is_empty():
					backend = BackendMode.AUDIO_CPP_NEURAL
			f.close()

	if audio_cpp_binary_path.is_empty():
		var bin_dir: String = AppPaths.get_data_dir().path_join("bin/audio.cpp")
		var possible_bins: Array[String] = [
			bin_dir.path_join("audiocpp_cli.exe"),
			bin_dir.path_join("audiocpp_cli"),
			bin_dir.path_join("audio.exe"),
			bin_dir.path_join("audio"),
			bin_dir.path_join("audiocpp_server.exe"),
			bin_dir.path_join("audiocpp_server"),
			bin_dir.path_join("audio.cpp.exe"),
			bin_dir.path_join("audio.cpp"),
			"audiocpp_cli.exe",
			"audiocpp_cli",
			"audio.exe",
			"audio",
			"bin/audio.cpp.exe",
			"bin/audio.cpp",
			"tools/audio.cpp.exe"
		]
		for p in possible_bins:
			if FileAccess.file_exists(p):
				audio_cpp_binary_path = p
				break

	if model_path.is_empty():
		var default_model: String = AppPaths.get_data_dir().path_join("models/audiogen-medium.q8_0.gguf")
		if FileAccess.file_exists(default_model):
			model_path = default_model

	if not audio_cpp_binary_path.is_empty() and OS.get_name() != "Windows":
		OS.execute("chmod", ["+x", audio_cpp_binary_path])

func generate_audio(prompt: String, duration_sec: float = 5.0, steps: int = 25, seed_val: int = -1) -> void:
	if is_generating:
		generation_failed.emit("Another sound generation is already in progress.")
		return

	var clean_prompt: String = prompt.strip_edges()
	if clean_prompt.is_empty():
		generation_failed.emit("Prompt cannot be empty.")
		return

	is_generating = true
	generation_started.emit(clean_prompt)

	var target_dir: String = AppPaths.get_default_samples_dir() + "/AI_Generated"
	if not DirAccess.dir_exists_absolute(target_dir):
		DirAccess.make_dir_recursive_absolute(target_dir)

	var timestamp: int = int(Time.get_unix_time_from_system())
	var sanitized_name: String = ""
	for c in clean_prompt.to_lower():
		if c in "abcdefghijklmnopqrstuvwxyz0123456789_":
			sanitized_name += c
		elif c == " ":
			sanitized_name += "_"
	sanitized_name = sanitized_name.substr(0, 32).strip_edges()
	if sanitized_name.is_empty():
		sanitized_name = "ai_sound"

	var out_filename: String = "%s_%d.wav" % [sanitized_name, timestamp]
	var out_filepath: String = target_dir + "/" + out_filename

	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		_finish_generation(clean_prompt, duration_sec, out_filepath, sanitized_name)
		return

	if audio_cpp_binary_path.is_empty() or not FileAccess.file_exists(audio_cpp_binary_path):
		is_generating = false
		generation_failed.emit("audio.cpp binary not configured. Please set the path in Settings.")
		return
		
	if model_path.is_empty() or not FileAccess.file_exists(model_path):
		is_generating = false
		generation_failed.emit("GGUF model not configured. Please set the path in Settings.")
		return

	_run_audio_cpp_subprocess(clean_prompt, duration_sec, steps, seed_val, out_filepath, sanitized_name, tree)

func _run_audio_cpp_subprocess(prompt: String, duration_sec: float, steps: int, seed_val: int, out_filepath: String, s_name: String, tree: SceneTree) -> void:
	var args: PackedStringArray = [
		"--prompt", prompt,
		"--duration", str(duration_sec),
		"--steps", str(steps),
		"-o", out_filepath,
		"--model", model_path
	]
	if seed_val >= 0:
		args.append("--seed")
		args.append(str(seed_val))

	var pid: int = OS.create_process(audio_cpp_binary_path, args)
	if pid <= 0:
		is_generating = false
		generation_failed.emit("Failed to execute audio.cpp binary at " + audio_cpp_binary_path)
		return

	# Monitor process in background
	_poll_audio_cpp_process(pid, prompt, duration_sec, out_filepath, s_name, 0.0, tree)

func _poll_audio_cpp_process(pid: int, prompt: String, duration_sec: float, out_filepath: String, s_name: String, elapsed: float, tree: SceneTree) -> void:
	tree.create_timer(0.2).timeout.connect(func():
		var new_elapsed: float = elapsed + 0.2
		var progress: float = clampf(new_elapsed / (duration_sec * 0.8 + 2.0), 0.1, 0.95)
		generation_progress.emit(progress)
		if not OS.is_process_running(pid):
			if FileAccess.file_exists(out_filepath):
				_finish_metadata(prompt, duration_sec, out_filepath, s_name, "Neural audio.cpp")
			else:
				is_generating = false
				generation_failed.emit("audio.cpp process exited without producing an output audio file.")
		else:
			_poll_audio_cpp_process(pid, prompt, duration_sec, out_filepath, s_name, new_elapsed, tree)
	)

func _run_procedural_dsp_generation(prompt: String, duration_sec: float, _steps: int, _seed_val: int, out_filepath: String, s_name: String, tree: SceneTree) -> void:
	var t1: SceneTreeTimer = tree.create_timer(0.3)
	t1.timeout.connect(func():
		generation_progress.emit(0.35)
		var t2: SceneTreeTimer = tree.create_timer(0.3)
		t2.timeout.connect(func():
			generation_progress.emit(0.75)
			var t3: SceneTreeTimer = tree.create_timer(0.3)
			t3.timeout.connect(func():
				generation_progress.emit(0.98)
				_finish_generation(prompt, duration_sec, out_filepath, s_name)
			)
		)
	)

func _finish_generation(prompt: String, duration_sec: float, out_filepath: String, s_name: String) -> void:
	var sample_rate: int = 44100
	var total_samples: int = int(duration_sec * float(sample_rate))
	var wav_data: PackedByteArray = PackedByteArray()
	wav_data.resize(total_samples * 2) # 16-bit mono

	var p_low: String = prompt.to_lower()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	# High-Fidelity Multi-Mode Acoustic Physical Synthesis
	if "wind" in p_low or "breeze" in p_low or "storm" in p_low or "air" in p_low:
		# Bandpass-filtered resonant brownian noise with slow sine-LFO sweeps
		var b0: float = 0.0
		var _b1: float = 0.0
		for i in range(total_samples):
			var t: float = float(i) / float(sample_rate)
			var white: float = rng.randf_range(-1.0, 1.0)
			# Pink/Brown integration
			b0 = 0.96 * b0 + white * 0.04
			# Chaotic wind gust LFO modulation
			var gust: float = 0.6 + 0.35 * sin(t * 0.45) + 0.2 * sin(t * 1.1 + 0.8)
			var wave: float = b0 * gust * 2.2
			var env: float = _calc_envelope(t, duration_sec)
			var sample_val: int = clampi(int(wave * env * 26000.0), -32767, 32767)
			wav_data.encode_s16(i * 2, sample_val)

	elif "thunder" in p_low or "explosion" in p_low or "boom" in p_low:
		# Low-frequency shockwave drop (55Hz -> 28Hz) + reverberant noise tail
		var phase: float = 0.0
		var b_rumble: float = 0.0
		for i in range(total_samples):
			var t: float = float(i) / float(sample_rate)
			var freq: float = 28.0 + 35.0 * exp(-t * 1.8)
			phase += TAU * freq / float(sample_rate)
			var white: float = rng.randf_range(-1.0, 1.0)
			b_rumble = 0.94 * b_rumble + white * 0.06
			var blast_env: float = exp(-t * 0.85)
			var wave: float = sin(phase) * blast_env * 0.8 + b_rumble * blast_env * 1.6
			var env: float = _calc_envelope(t, duration_sec)
			var sample_val: int = clampi(int(wave * env * 28000.0), -32767, 32767)
			wav_data.encode_s16(i * 2, sample_val)

	elif "fire" in p_low or "hearth" in p_low or "campfire" in p_low or "flame" in p_low:
		# Flame roar (pink noise) + stochastic Poisson crackle clicks
		var b_flame: float = 0.0
		for i in range(total_samples):
			var t: float = float(i) / float(sample_rate)
			var white: float = rng.randf_range(-1.0, 1.0)
			b_flame = 0.92 * b_flame + white * 0.08
			var crackle: float = 0.0
			if rng.randf() < 0.0035: # Poisson snap click
				crackle = rng.randf_range(-1.0, 1.0) * rng.randf_range(0.5, 1.0)
			var wave: float = b_flame * 0.55 + crackle * 0.85
			var env: float = _calc_envelope(t, duration_sec)
			var sample_val: int = clampi(int(wave * env * 24000.0), -32767, 32767)
			wav_data.encode_s16(i * 2, sample_val)

	elif "water" in p_low or "rain" in p_low or "ocean" in p_low or "river" in p_low or "stream" in p_low:
		# Multi-droplet stochastic granular Poisson impulses + soft swell
		var b_bed: float = 0.0
		for i in range(total_samples):
			var t: float = float(i) / float(sample_rate)
			var white: float = rng.randf_range(-1.0, 1.0)
			b_bed = 0.88 * b_bed + white * 0.12
			var drip: float = 0.0
			if rng.randf() < 0.035:
				drip = rng.randf_range(-0.6, 0.6)
			var swell: float = 0.75 + 0.25 * sin(t * 0.6)
			var wave: float = (b_bed * 0.4 + drip * 0.6) * swell
			var env: float = _calc_envelope(t, duration_sec)
			var sample_val: int = clampi(int(wave * env * 25000.0), -32767, 32767)
			wav_data.encode_s16(i * 2, sample_val)

	elif "bell" in p_low or "chime" in p_low or "gong" in p_low:
		# Exact acoustic modal inharmonic bell synthesis
		var f0: float = 380.0
		var partials: Array[float] = [1.0, 2.76, 5.40, 8.93, 13.34]
		var amps: Array[float] = [0.45, 0.28, 0.16, 0.08, 0.04]
		var decays: Array[float] = [0.8, 1.4, 2.5, 3.8, 5.5]
		for i in range(total_samples):
			var t: float = float(i) / float(sample_rate)
			var wave: float = 0.0
			for k in range(partials.size()):
				wave += sin(TAU * f0 * partials[k] * t) * amps[k] * exp(-t * decays[k])
			var env: float = _calc_envelope(t, duration_sec)
			var sample_val: int = clampi(int(wave * env * 27000.0), -32767, 32767)
			wav_data.encode_s16(i * 2, sample_val)

	else:
		# Ambient atmospheric drone pad (5 detuned harmonic voices)
		var base_f: float = 146.83 # D3
		for i in range(total_samples):
			var t: float = float(i) / float(sample_rate)
			var wave: float = (
				sin(TAU * base_f * 1.000 * t) * 0.35 +
				sin(TAU * base_f * 1.006 * t) * 0.25 +
				sin(TAU * base_f * 1.498 * t) * 0.20 + # Fifth
				sin(TAU * base_f * 2.002 * t) * 0.15 + # Octave
				sin(TAU * base_f * 2.247 * t) * 0.10   # 9th
			)
			var lfo: float = 0.85 + 0.15 * sin(t * 0.8)
			var env: float = _calc_envelope(t, duration_sec)
			var sample_val: int = clampi(int(wave * lfo * env * 24000.0), -32767, 32767)
			wav_data.encode_s16(i * 2, sample_val)

	# Write standard RIFF WAV file
	var f: FileAccess = FileAccess.open(out_filepath, FileAccess.WRITE)
	if f:
		f.store_string("RIFF")
		f.store_32(36 + wav_data.size())
		f.store_string("WAVEfmt ")
		f.store_32(16)
		f.store_16(1)  # PCM
		f.store_16(1)  # Mono
		f.store_32(sample_rate)
		f.store_32(sample_rate * 2)
		f.store_16(2)
		f.store_16(16)
		f.store_string("data")
		f.store_32(wav_data.size())
		f.store_buffer(wav_data)
		f.close()

	_finish_metadata(prompt, duration_sec, out_filepath, s_name, "Procedural Physical DSP Synthesis")

func _calc_envelope(t: float, total_dur: float) -> float:
	var fade: float = minf(total_dur * 0.1, 0.4)
	if t < fade:
		return t / fade
	elif t > total_dur - fade:
		return (total_dur - t) / fade
	return 1.0

func _finish_metadata(prompt: String, duration_sec: float, out_filepath: String, s_name: String, backend_name: String) -> void:
	var meta: Dictionary = {
		"name": s_name.replace("_", " ").capitalize(),
		"prompt": prompt,
		"duration": duration_sec,
		"source": "Local AI Audio Engine (%s)" % backend_name,
		"generated_at": Time.get_datetime_string_from_system()
	}

	var meta_f: FileAccess = FileAccess.open(out_filepath.get_basename() + ".json", FileAccess.WRITE)
	if meta_f:
		meta_f.store_string(JSON.stringify(meta, "\t"))
		meta_f.close()

	is_generating = false
	generation_completed.emit(s_name.replace("_", " ").capitalize(), out_filepath, meta)
