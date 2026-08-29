class_name LibraryManager
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir

const LIBRARY_ROOT: String = "user://library"

static func ensure_library_directory() -> void:
	var global_path: String = ProjectSettings.globalize_path(LIBRARY_ROOT)
	if not DirAccess.dir_exists_absolute(global_path):
		DirAccess.make_dir_recursive_absolute(global_path)

static func get_all_soundscapes() -> Array[Dictionary]:
	ensure_library_directory()
	var results: Array[Dictionary] = []
	var global_root: String = ProjectSettings.globalize_path(LIBRARY_ROOT)
	var dir: DirAccess = DirAccess.open(global_root)

	if dir == null:
		return results

	dir.list_dir_begin()
	var folder_name: String = dir.get_next()

	while not folder_name.is_empty():
		if dir.current_is_dir() and not folder_name.begins_with("."):
			var folder_path: String = LIBRARY_ROOT + "/" + folder_name
			var project_path: String = folder_path + "/project.ambmix"
			var meta_path: String = folder_path + "/metadata.json"
			var cover_path: String = ""

			for ext in ["jpg", "jpeg", "png", "webp"]:
				var test_cov: String = folder_path + "/cover." + ext
				if FileAccess.file_exists(ProjectSettings.globalize_path(test_cov)):
					cover_path = test_cov
					break

			var info: Dictionary = {
				"folder_name": folder_name,
				"folder_path": folder_path,
				"project_path": project_path,
				"has_project": FileAccess.file_exists(ProjectSettings.globalize_path(project_path)),
				"title": folder_name.capitalize(),
				"description": "",
				"author": "Unknown",
				"cover_path": cover_path
			}

			if FileAccess.file_exists(ProjectSettings.globalize_path(meta_path)):
				var meta_file: FileAccess = FileAccess.open(ProjectSettings.globalize_path(meta_path), FileAccess.READ)
				if meta_file != null:
					var test_json: JSON = JSON.new()
					if test_json.parse(meta_file.get_as_text()) == OK:
						var meta_dict: Dictionary = test_json.get_data() as Dictionary
						info["title"] = meta_dict.get("title", info["title"])
						info["description"] = meta_dict.get("description", "")
						info["author"] = meta_dict.get("author", "Unknown")
						var meta_cover: String = meta_dict.get("cover", meta_dict.get("cover_image_path", ""))
						if not meta_cover.is_empty() and FileAccess.file_exists(ProjectSettings.globalize_path(meta_cover)):
							info["cover_path"] = meta_cover
					meta_file.close()

			results.append(info)

		folder_name = dir.get_next()

	dir.list_dir_end()
	return results

static func list_soundscapes() -> Array[SoundscapeData.SoundscapeProject]:
	ensure_library_directory()
	var projects: Array[SoundscapeData.SoundscapeProject] = []
	var list: Array[Dictionary] = get_all_soundscapes()
	for item in list:
		var proj_path: String = item["project_path"]
		var proj: SoundscapeData.SoundscapeProject = load_project_file(proj_path)
		if proj:
			projects.append(proj)
		else:
			var p: SoundscapeData.SoundscapeProject = SoundscapeData.SoundscapeProject.new()
			p.title = item["title"]
			p.author = item["author"]
			p.description = item["description"]
			projects.append(p)
	return projects

static func load_project_file(path: String) -> SoundscapeData.SoundscapeProject:
	var global_p: String = ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(global_p):
		return null
	var file: FileAccess = FileAccess.open(global_p, FileAccess.READ)
	if file == null:
		return null
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
		return SoundscapeData.SoundscapeProject.from_dict(json.data)
	return null

static func save_soundscape(project: SoundscapeData.SoundscapeProject, target_folder: String = "") -> String:
	ensure_library_directory()
	if project == null:
		return ""

	var folder_name: String = ""
	if not target_folder.is_empty():
		folder_name = target_folder.get_file()
		if folder_name.ends_with(".ambmix"):
			folder_name = target_folder.get_base_dir().get_file()
	elif not project.source_path.is_empty() and project.source_path.begins_with(LIBRARY_ROOT):
		folder_name = project.source_path.replace(LIBRARY_ROOT + "/", "").split("/")[0]
	else:
		folder_name = AmbientMixerClient.sanitize_filename(project.title)

	if folder_name.is_empty():
		folder_name = "custom_soundscape"

	var folder_path: String = LIBRARY_ROOT + "/" + folder_name
	var global_folder: String = ProjectSettings.globalize_path(folder_path)
	if not DirAccess.dir_exists_absolute(global_folder):
		DirAccess.make_dir_recursive_absolute(global_folder)

	# Copy cover image into library folder if it's from an external path
	if not project.cover_image_path.is_empty():
		var ext: String = project.cover_image_path.get_extension().to_lower()
		if ext.is_empty(): ext = "png"
		var target_cover_rel: String = folder_path + "/cover." + ext
		var global_target_cover: String = ProjectSettings.globalize_path(target_cover_rel)
		var global_src_cover: String = ProjectSettings.globalize_path(project.cover_image_path)
		
		if FileAccess.file_exists(global_src_cover) and global_src_cover != global_target_cover:
			DirAccess.copy_absolute(global_src_cover, global_target_cover)
			project.cover_image_path = target_cover_rel

	var proj_path: String = folder_path + "/project.ambmix"
	project.save_to_file(proj_path)

	# Update / create metadata.json
	var meta_path: String = folder_path + "/metadata.json"
	var existing_meta: Dictionary = {}
	var global_meta: String = ProjectSettings.globalize_path(meta_path)
	if FileAccess.file_exists(global_meta):
		var f_read: FileAccess = FileAccess.open(global_meta, FileAccess.READ)
		if f_read != null:
			var json_obj: JSON = JSON.new()
			if json_obj.parse(f_read.get_as_text()) == OK and json_obj.data is Dictionary:
				existing_meta = json_obj.data
			f_read.close()

	existing_meta["title"] = project.title
	existing_meta["author"] = project.author
	existing_meta["description"] = project.description
	existing_meta["track_count"] = project.tracks.size()
	if not project.cover_image_path.is_empty():
		existing_meta["cover"] = project.cover_image_path
	existing_meta["last_modified"] = Time.get_datetime_string_from_system()

	var f_write: FileAccess = FileAccess.open(global_meta, FileAccess.WRITE)
	if f_write != null:
		f_write.store_string(JSON.stringify(existing_meta, "\t"))
		f_write.close()

	return proj_path

static func save_project(project: SoundscapeData.SoundscapeProject, path: String) -> bool:
	var global_p: String = ProjectSettings.globalize_path(path)
	var file: FileAccess = FileAccess.open(global_p, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(project.to_dict(), "\t"))
	return true

static func delete_soundscape(folder_name: String) -> bool:
	var path: String = ProjectSettings.globalize_path(LIBRARY_ROOT + "/" + folder_name)
	if not DirAccess.dir_exists_absolute(path):
		return false
	return _remove_dir_recursive(path)

static func _remove_dir_recursive(path: String) -> bool:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return false

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while not file_name.is_empty():
		if file_name != "." and file_name != "..":
			var sub_path: String = path.path_join(file_name)
			if dir.current_is_dir():
				_remove_dir_recursive(sub_path)
			else:
				DirAccess.remove_absolute(sub_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	return DirAccess.remove_absolute(path) == OK
