class_name AppPaths
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir/3D-Soundscape-Studio

static func get_data_dir() -> String:
	var base_dir: String = ""
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://")
	else:
		base_dir = OS.get_executable_path().get_base_dir()
		if base_dir.is_empty():
			base_dir = "."
	var data_path: String = base_dir.path_join("data")
	if not DirAccess.dir_exists_absolute(data_path):
		DirAccess.make_dir_recursive_absolute(data_path)
	return data_path

static func get_settings_file() -> String:
	return get_data_dir().path_join("settings.json")

static func get_recent_projects_file() -> String:
	return get_data_dir().path_join("recent_projects.json")

static func get_soundscape_categories_file() -> String:
	return get_data_dir().path_join("soundscape_categories.json")

static func get_sample_categories_file() -> String:
	return get_data_dir().path_join("sample_categories.json")

static func get_sample_metadata_file() -> String:
	return get_data_dir().path_join("sample_metadata.json")

static func get_default_library_dir() -> String:
	var p: String = get_data_dir().path_join("library")
	if not DirAccess.dir_exists_absolute(p):
		DirAccess.make_dir_recursive_absolute(p)
	return p

static func get_default_samples_dir() -> String:
	var p: String = get_data_dir().path_join("samples")
	if not DirAccess.dir_exists_absolute(p):
		DirAccess.make_dir_recursive_absolute(p)
	return p

static func get_default_exports_dir() -> String:
	var p: String = get_data_dir().path_join("exports")
	if not DirAccess.dir_exists_absolute(p):
		DirAccess.make_dir_recursive_absolute(p)
	return p

static func get_default_sofa_dir() -> String:
	var p: String = get_data_dir().path_join("sofa")
	if not DirAccess.dir_exists_absolute(p):
		DirAccess.make_dir_recursive_absolute(p)
	return p

static func get_default_updates_dir() -> String:
	var p: String = get_data_dir().path_join("updates")
	if not DirAccess.dir_exists_absolute(p):
		DirAccess.make_dir_recursive_absolute(p)
	return p

