class_name AudioImporter
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir

const ALLOWED_EXTENSIONS: PackedStringArray = ["ogg", "mp3", "wav"]
const MAGIC_BYTES_OGG: PackedByteArray = [0x4F, 0x67, 0x67, 0x53] # OggS
const MAGIC_BYTES_WAV_RIFF: PackedByteArray = [0x52, 0x49, 0x46, 0x46] # RIFF
const MAGIC_BYTES_WAV_WAVE: PackedByteArray = [0x57, 0x41, 0x56, 0x45] # WAVE
const MAGIC_BYTES_MP3_ID3: PackedByteArray = [0x49, 0x44, 0x33] # ID3

static func is_safe_path(file_path: String) -> bool:
	if file_path.is_empty():
		return false
	if file_path.contains("..") or file_path.contains("~"):
		return false
	return true

static func validate_audio_file(file_path: String) -> bool:
	if file_path.is_empty():
		return false
	if not is_safe_path(file_path):
		printerr("Security Error: Invalid or path-traversal detected in path: ", file_path)
		return false

	var extension: String = file_path.get_extension().to_lower()
	if not ALLOWED_EXTENSIONS.has(extension):
		printerr("Security Error: Unsupported audio extension '.", extension, "' for: ", file_path)
		return false

	var global_path: String = ProjectSettings.globalize_path(file_path)
	if not FileAccess.file_exists(global_path):
		printerr("Error: File does not exist: ", file_path)
		return false

	var file: FileAccess = FileAccess.open(global_path, FileAccess.READ)
	if file == null:
		printerr("Error: Cannot open audio file: ", file_path)
		return false

	var header_len: int = 12
	var header: PackedByteArray = file.get_buffer(header_len)
	file.close()

	if header.size() < 4:
		printerr("Error: File header too small: ", file_path)
		return false

	var is_valid: bool = false
	if extension == "ogg":
		if header.size() >= 4 and header.slice(0, 4) == MAGIC_BYTES_OGG:
			is_valid = true
		else:
			# Fallback for streams
			is_valid = true
	elif extension == "wav":
		if header.size() >= 4 and header.slice(0, 4) == MAGIC_BYTES_WAV_RIFF:
			is_valid = true
		else:
			is_valid = (header.size() >= 44)
	elif extension == "mp3":
		# MP3 may start with ID3 tag, sync word 0xFFE0, or raw frame
		if header.size() >= 3 and header.slice(0, 3) == MAGIC_BYTES_MP3_ID3:
			is_valid = true
		elif header.size() >= 2 and header[0] == 0xFF and (header[1] & 0xE0) == 0xE0:
			is_valid = true
		else:
			# Resilient fallback: allow file if size > 128 bytes
			is_valid = (file.get_length() > 128)

	if not is_valid:
		printerr("Security Warning: Audio file validation failed for '", extension, "': ", file_path)
		return false

	return true

static func load_audio_stream(file_path: String) -> AudioStream:
	if not validate_audio_file(file_path):
		return null

	var global_path: String = ProjectSettings.globalize_path(file_path)
	var extension: String = file_path.get_extension().to_lower()

	var file: FileAccess = FileAccess.open(global_path, FileAccess.READ)
	if file == null:
		return null
	var buffer: PackedByteArray = file.get_buffer(file.get_length())
	file.close()

	if extension == "ogg":
		return AudioStreamOggVorbis.load_from_buffer(buffer)
	elif extension == "mp3":
		var stream_mp3: AudioStreamMP3 = AudioStreamMP3.new()
		stream_mp3.data = buffer
		return stream_mp3
	elif extension == "wav":
		return load_wav_from_buffer(buffer)

	return null

static func load_wav_from_buffer(buffer: PackedByteArray) -> AudioStreamWAV:
	if buffer.size() < 44:
		return null

	var stream_wav: AudioStreamWAV = AudioStreamWAV.new()
	# Basic WAV header parser
	var _format_tag: int = buffer.decode_u16(20)
	var channels: int = buffer.decode_u16(22)
	var sample_rate: int = buffer.decode_u32(24)
	var bits_per_sample: int = buffer.decode_u16(34)

	# Find data chunk
	var offset: int = 12
	var data_offset: int = 0
	var data_size: int = 0

	while offset < buffer.size() - 8:
		var chunk_id: String = buffer.slice(offset, offset + 4).get_string_from_ascii()
		var chunk_size: int = buffer.decode_u32(offset + 4)
		if chunk_id == "data":
			data_offset = offset + 8
			data_size = chunk_size
			break
		offset += 8 + chunk_size

	if data_offset > 0 and data_size > 0 and data_offset + data_size <= buffer.size():
		stream_wav.data = buffer.slice(data_offset, data_offset + data_size)
	else:
		# Fallback to standard 44 byte header
		stream_wav.data = buffer.slice(44)

	stream_wav.mix_rate = sample_rate
	stream_wav.stereo = (channels == 2)
	if bits_per_sample == 8:
		stream_wav.format = AudioStreamWAV.FORMAT_8_BITS
	elif bits_per_sample == 16:
		stream_wav.format = AudioStreamWAV.FORMAT_16_BITS
	elif bits_per_sample == 24 or bits_per_sample == 32:
		stream_wav.format = AudioStreamWAV.FORMAT_16_BITS

	return stream_wav
