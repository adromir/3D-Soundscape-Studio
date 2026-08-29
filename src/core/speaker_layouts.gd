class_name SpeakerLayouts
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir

enum LayoutType {
	BINAURAL_SOFA,
	STEREO,
	QUADRAPHONIC,
	SURROUND_5_1,
	SURROUND_7_1
}

const LAYOUT_NAMES: Dictionary = {
	LayoutType.BINAURAL_SOFA: "Binaural (HRTF / Headphones)",
	LayoutType.STEREO: "Stereo (2.0)",
	LayoutType.QUADRAPHONIC: "Quadraphonic (4.0)",
	LayoutType.SURROUND_5_1: "Surround (5.1)",
	LayoutType.SURROUND_7_1: "Surround (7.1)"
}

const FFMPEG_CHANNEL_LAYOUTS: Dictionary = {
	LayoutType.BINAURAL_SOFA: "stereo",
	LayoutType.STEREO: "stereo",
	LayoutType.QUADRAPHONIC: "quad",
	LayoutType.SURROUND_5_1: "5.1",
	LayoutType.SURROUND_7_1: "7.1"
}

const CHANNEL_COUNTS: Dictionary = {
	LayoutType.BINAURAL_SOFA: 2,
	LayoutType.STEREO: 2,
	LayoutType.QUADRAPHONIC: 4,
	LayoutType.SURROUND_5_1: 6,
	LayoutType.SURROUND_7_1: 8
}

## Speaker angles in degrees (Azimuth: 0 = Front, 90 = Right, 180/-180 = Back, -90 = Left)
const SPEAKER_POSITIONS: Dictionary = {
	LayoutType.STEREO: {
		"FL": -30.0,
		"FR": 30.0
	},
	LayoutType.QUADRAPHONIC: {
		"FL": -45.0,
		"FR": 45.0,
		"RL": -135.0,
		"RR": 135.0
	},
	LayoutType.SURROUND_5_1: {
		"FL": -30.0,
		"FR": 30.0,
		"FC": 0.0,
		"LFE": 0.0,
		"SL": -110.0,
		"SR": 110.0
	},
	LayoutType.SURROUND_7_1: {
		"FL": -30.0,
		"FR": 30.0,
		"FC": 0.0,
		"LFE": 0.0,
		"BL": -150.0,
		"BR": 150.0,
		"SL": -90.0,
		"SR": 90.0
	}
}

static func get_layout_name(layout: LayoutType) -> String:
	return LAYOUT_NAMES.get(layout, "Unknown")

static func get_channel_count(layout: LayoutType) -> int:
	return CHANNEL_COUNTS.get(layout, 2)

static func get_ffmpeg_layout_name(layout: LayoutType) -> String:
	return FFMPEG_CHANNEL_LAYOUTS.get(layout, "stereo")
