class_name LibraryManager
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir


static func get_library_root() -> String:
	return AppPaths.get_default_library_dir()

static func ensure_library_directory() -> void:
	var global_path: String = get_library_root()
	if not DirAccess.dir_exists_absolute(global_path):
		DirAccess.make_dir_recursive_absolute(global_path)

static func get_all_soundscapes() -> Array[Dictionary]:
	ensure_library_directory()
	var results: Array[Dictionary] = []
	var global_root: String = get_library_root()
	var dir: DirAccess = DirAccess.open(global_root)

	if dir == null:
		return results

	dir.list_dir_begin()
	var folder_name: String = dir.get_next()

	while not folder_name.is_empty():
		if dir.current_is_dir() and not folder_name.begins_with("."):
			var folder_path: String = global_root.path_join(folder_name)
			var project_path: String = folder_path.path_join("project.ambmix")
			var meta_path: String = folder_path.path_join("metadata.json")
			var cover_path: String = ""

			for ext in ["jpg", "jpeg", "png", "webp"]:
				var test_cov: String = folder_path.path_join("cover." + ext)
				if FileAccess.file_exists(test_cov):
					cover_path = test_cov
					break

			var info: Dictionary = {
				"folder_name": folder_name,
				"folder_path": folder_path,
				"project_path": project_path,
				"has_project": FileAccess.file_exists(ProjectSettings.globalize_path(project_path)),
				"title": folder_name.capitalize(),
				"category": "Nature",
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
						info["category"] = meta_dict.get("category", "Nature")
						info["description"] = meta_dict.get("description", "")
						info["author"] = meta_dict.get("author", "Unknown")
						var meta_cover: String = meta_dict.get("cover", meta_dict.get("cover_image_path", ""))
						if not meta_cover.is_empty() and FileAccess.file_exists(ProjectSettings.globalize_path(meta_cover)):
							info["cover_path"] = meta_cover
					meta_file.close()
			elif info["has_project"]:
				var proj: SoundscapeData.SoundscapeProject = load_project_file(project_path)
				if proj:
					info["title"] = proj.title
					info["category"] = proj.category
					info["author"] = proj.author
					info["description"] = proj.description

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
	var proj: SoundscapeData.SoundscapeProject = SoundscapeData.SoundscapeProject.load_from_file(global_p)
	return proj

static func save_soundscape(project: SoundscapeData.SoundscapeProject, target_folder: String = "") -> String:
	ensure_library_directory()
	if project == null:
		return ""

	var folder_name: String = ""
	if not target_folder.is_empty():
		folder_name = target_folder.get_file()
		if folder_name.ends_with(".ambmix"):
			folder_name = target_folder.get_base_dir().get_file()
	elif not project.source_path.is_empty() and project.source_path.begins_with(get_library_root()):
		folder_name = project.source_path.replace(get_library_root() + "/", "").split("/")[0]
	else:
		folder_name = AmbientMixerClient.sanitize_filename(project.title)

	if folder_name.is_empty():
		folder_name = "custom_soundscape"

	var folder_path: String = get_library_root().path_join(folder_name)
	var global_folder: String = folder_path
	if not DirAccess.dir_exists_absolute(global_folder):
		DirAccess.make_dir_recursive_absolute(global_folder)

	# Copy cover image into library folder if it's from an external path
	if not project.cover_image_path.is_empty():
		var ext: String = project.cover_image_path.get_extension().to_lower()
		if ext.is_empty(): ext = "png"
		var target_cover_rel: String = folder_path.path_join("cover." + ext)
		var global_target_cover: String = target_cover_rel
		var global_src_cover: String = ProjectSettings.globalize_path(project.cover_image_path)
		
		if FileAccess.file_exists(global_src_cover) and global_src_cover != global_target_cover:
			DirAccess.copy_absolute(global_src_cover, global_target_cover)
			project.cover_image_path = target_cover_rel

	var proj_path: String = folder_path.path_join("project.ambmix")
	project.save_to_file(proj_path)

	# Update / create metadata.json
	var meta_path: String = folder_path.path_join("metadata.json")
	var existing_meta: Dictionary = {}
	var global_meta: String = meta_path
	if FileAccess.file_exists(global_meta):
		var f_read: FileAccess = FileAccess.open(global_meta, FileAccess.READ)
		if f_read != null:
			var json_obj: JSON = JSON.new()
			if json_obj.parse(f_read.get_as_text()) == OK and json_obj.data is Dictionary:
				existing_meta = json_obj.data
			f_read.close()

	existing_meta["title"] = project.title
	existing_meta["category"] = project.category
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
	var json_str: String = JSON.stringify(project.to_dict(), "\t")
	file.store_string(json_str)
	file.close()
	return true

static func update_soundscape_info(folder_or_slug: String, new_title: String, new_category: String, new_author: String = "") -> bool:
	if folder_or_slug.is_empty():
		return false

	var folder_name: String = folder_or_slug
	if folder_or_slug.begins_with(get_library_root()):
		folder_name = folder_or_slug.replace(get_library_root() + "/", "").split("/")[0]

	var folder_path: String = get_library_root().path_join(folder_name)
	var proj_file: String = folder_path.path_join("project.ambmix")
	var meta_file: String = folder_path.path_join("metadata.json")

	# Update project.ambmix
	if FileAccess.file_exists(ProjectSettings.globalize_path(proj_file)):
		var proj: SoundscapeData.SoundscapeProject = load_project_file(proj_file)
		if proj:
			if not new_title.is_empty(): proj.title = new_title
			if not new_category.is_empty(): proj.category = new_category
			if not new_author.is_empty(): proj.author = new_author
			proj.save_to_file(proj_file)

	# Update metadata.json
	var existing_meta: Dictionary = {}
	if FileAccess.file_exists(ProjectSettings.globalize_path(meta_file)):
		var f_read: FileAccess = FileAccess.open(ProjectSettings.globalize_path(meta_file), FileAccess.READ)
		if f_read != null:
			var json_obj: JSON = JSON.new()
			if json_obj.parse(f_read.get_as_text()) == OK and json_obj.data is Dictionary:
				existing_meta = json_obj.data
			f_read.close()

	if not new_title.is_empty(): existing_meta["title"] = new_title
	if not new_category.is_empty(): existing_meta["category"] = new_category
	if not new_author.is_empty(): existing_meta["author"] = new_author
	existing_meta["last_modified"] = Time.get_datetime_string_from_system()

	var f_write: FileAccess = FileAccess.open(ProjectSettings.globalize_path(meta_file), FileAccess.WRITE)
	if f_write != null:
		f_write.store_string(JSON.stringify(existing_meta, "\t"))
		f_write.close()
		return true
	return false

static func delete_soundscape(folder_name: String) -> bool:
	var path: String = get_library_root().path_join(folder_name)
	if not DirAccess.dir_exists_absolute(path):
		return false
	return _remove_dir_recursive(path)

static func load_soundscape(path: String) -> SoundscapeData.SoundscapeProject:
	return load_project_file(path)

static func load_soundscape_cover_texture(target: String) -> ImageTexture:
	var file_to_load: String = ""
	if target.begins_with("res://") or target.begins_with("user://") or target.is_absolute_path():
		file_to_load = ProjectSettings.globalize_path(target)
	else:
		# Slug or folder name
		var base_folder: String = get_library_root().path_join(target)
		for ext in ["jpg", "jpeg", "png", "webp"]:
			var test_path: String = base_folder.path_join("cover." + ext)
			if FileAccess.file_exists(test_path):
				file_to_load = test_path
				break

	if not file_to_load.is_empty() and FileAccess.file_exists(file_to_load):
		var img: Image = Image.new()
		if img.load(file_to_load) == OK:
			return ImageTexture.create_from_image(img)
	return null

static func set_soundscape_cover(folder_or_slug: String, source_image_path: String) -> bool:
	if folder_or_slug.is_empty() or source_image_path.is_empty():
		return false

	var folder_name: String = folder_or_slug
	if folder_or_slug.begins_with(get_library_root()):
		folder_name = folder_or_slug.replace(get_library_root() + "/", "").split("/")[0]

	var folder_path: String = get_library_root().path_join(folder_name)
	var global_folder: String = folder_path
	if not DirAccess.dir_exists_absolute(global_folder):
		DirAccess.make_dir_recursive_absolute(global_folder)

	var ext: String = source_image_path.get_extension().to_lower()
	if ext.is_empty(): ext = "png"
	var target_cover_rel: String = folder_path.path_join("cover." + ext)
	var global_target: String = ProjectSettings.globalize_path(target_cover_rel)
	var global_src: String = ProjectSettings.globalize_path(source_image_path)

	if FileAccess.file_exists(global_src):
		DirAccess.copy_absolute(global_src, global_target)

		# Update metadata.json
		var meta_path: String = folder_path + "/metadata.json"
		var global_meta: String = ProjectSettings.globalize_path(meta_path)
		var existing_meta: Dictionary = {}
		if FileAccess.file_exists(global_meta):
			var f_read: FileAccess = FileAccess.open(global_meta, FileAccess.READ)
			if f_read != null:
				var json_obj: JSON = JSON.new()
				if json_obj.parse(f_read.get_as_text()) == OK and json_obj.data is Dictionary:
					existing_meta = json_obj.data
				f_read.close()

		existing_meta["cover"] = target_cover_rel
		existing_meta["last_modified"] = Time.get_datetime_string_from_system()

		var f_write: FileAccess = FileAccess.open(global_meta, FileAccess.WRITE)
		if f_write != null:
			f_write.store_string(JSON.stringify(existing_meta, "\t"))
			f_write.close()
		return true
	return false

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

# ==================== PORTABLE PACKAGE EXPORT & IMPORT (.3dscape) ====================

static func export_soundscape_package(project: SoundscapeData.SoundscapeProject, output_zip_path: String) -> bool:
	if project == null or output_zip_path.is_empty():
		return false

	var global_out: String = ProjectSettings.globalize_path(output_zip_path)
	var parent_dir: String = global_out.get_base_dir()
	if not DirAccess.dir_exists_absolute(parent_dir):
		DirAccess.make_dir_recursive_absolute(parent_dir)

	var packer: ZIPPacker = ZIPPacker.new()
	var err: Error = packer.open(global_out)
	if err != OK:
		printerr("Failed to open ZIPPacker for: ", global_out, " error: ", err)
		return false

	var proj_dict: Dictionary = project.to_dict()
	var exported_tracks: Array = []

	# 1. Package Audio Stems
	var audio_idx: int = 1
	for track in project.tracks:
		var t_dict: Dictionary = track.to_dict()
		var src_path: String = track.file_path
		var file_bytes: PackedByteArray = PackedByteArray()
		var dest_filename: String = ""

		if not src_path.is_empty():
			var test_paths: Array[String] = [
				src_path,
				ProjectSettings.globalize_path(src_path),
				AppPaths.get_default_samples_dir().path_join(src_path.get_file()),
			]
			if not project.source_path.is_empty():
				test_paths.append(project.source_path.get_base_dir().path_join(src_path.get_file()))
				test_paths.append(project.source_path.get_base_dir().path_join("audio").path_join(src_path.get_file()))

			var found_path: String = ""
			for tp in test_paths:
				if FileAccess.file_exists(tp):
					found_path = tp
					break

			if not found_path.is_empty():
				file_bytes = FileAccess.get_file_as_bytes(found_path)
				var ext: String = found_path.get_extension()
				if ext.is_empty(): ext = "ogg"
				var clean_name: String = AmbientMixerClient.sanitize_filename(track.name)
				if clean_name.is_empty(): clean_name = "stem_%d" % audio_idx
				dest_filename = "%02d_%s.%s" % [audio_idx, clean_name, ext]

		if not file_bytes.is_empty() and not dest_filename.is_empty():
			var zip_audio_path: String = "audio/" + dest_filename
			packer.start_file(zip_audio_path)
			packer.write_file(file_bytes)
			packer.close_file()
			t_dict["file_path"] = zip_audio_path
		else:
			t_dict["file_path"] = src_path.get_file()

		exported_tracks.append(t_dict)
		audio_idx += 1

	proj_dict["tracks"] = exported_tracks

	# 2. Package Cover Artwork
	var cover_dest: String = ""
	if not project.cover_image_path.is_empty():
		var test_cov_paths: Array[String] = [
			project.cover_image_path,
			ProjectSettings.globalize_path(project.cover_image_path)
		]
		if not project.source_path.is_empty():
			test_cov_paths.append(project.source_path.get_base_dir().path_join(project.cover_image_path.get_file()))

		var found_cov: String = ""
		for cp in test_cov_paths:
			if FileAccess.file_exists(cp):
				found_cov = cp
				break

		if not found_cov.is_empty():
			var cov_bytes: PackedByteArray = FileAccess.get_file_as_bytes(found_cov)
			if not cov_bytes.is_empty():
				var ext: String = found_cov.get_extension().to_lower()
				if ext.is_empty(): ext = "png"
				cover_dest = "cover." + ext
				packer.start_file(cover_dest)
				packer.write_file(cov_bytes)
				packer.close_file()
				proj_dict["cover_image_path"] = cover_dest

	if cover_dest.is_empty():
		proj_dict["cover_image_path"] = ""

	# 3. Package metadata.json
	var meta_dict: Dictionary = {
		"title": project.title,
		"category": project.category,
		"author": project.author,
		"description": project.description,
		"track_count": project.tracks.size(),
		"cover": cover_dest,
		"format_version": 1,
		"generator": "3D Soundscape Studio",
		"export_date": Time.get_datetime_string_from_system()
	}
	packer.start_file("metadata.json")
	packer.write_file(JSON.stringify(meta_dict, "\t").to_utf8_buffer())
	packer.close_file()

	# 4. Package project.ambmix
	packer.start_file("project.ambmix")
	packer.write_file(JSON.stringify(proj_dict, "\t").to_utf8_buffer())
	packer.close_file()

	packer.close()
	print("✔ Successfully exported Soundscape Package to: ", global_out)
	return true

static func export_soundscape_by_folder(folder_name_or_slug: String, output_zip_path: String) -> bool:
	if folder_name_or_slug.is_empty() or output_zip_path.is_empty():
		return false

	var folder_name: String = folder_name_or_slug
	if folder_name_or_slug.begins_with(get_library_root()):
		folder_name = folder_name_or_slug.replace(get_library_root() + "/", "").split("/")[0]

	var proj_file: String = get_library_root().path_join(folder_name).path_join("project.ambmix")
	var proj: SoundscapeData.SoundscapeProject = load_project_file(proj_file)
	if proj == null:
		printerr("Could not load project to export from: ", proj_file)
		return false

	return export_soundscape_package(proj, output_zip_path)

static func import_soundscape_package(archive_path: String) -> SoundscapeData.SoundscapeProject:
	ensure_library_directory()
	var global_archive: String = ProjectSettings.globalize_path(archive_path)
	if not FileAccess.file_exists(global_archive):
		printerr("Soundscape package does not exist: ", global_archive)
		return null

	var reader: ZIPReader = ZIPReader.new()
	var err: Error = reader.open(global_archive)
	if err != OK:
		printerr("Failed to open ZIP package: ", global_archive, " error: ", err)
		return null

	var file_list: PackedStringArray = reader.get_files()
	if file_list.is_empty():
		printerr("ZIP package is empty!")
		reader.close()
		return null

	# Inspect metadata or project.ambmix for title
	var package_title: String = archive_path.get_file().get_basename()
	var package_category: String = "Custom"
	var project_json_str: String = ""

	if file_list.has("metadata.json"):
		var meta_bytes: PackedByteArray = reader.read_file("metadata.json")
		var json_obj: JSON = JSON.new()
		if json_obj.parse(meta_bytes.get_string_from_utf8()) == OK and json_obj.data is Dictionary:
			package_title = json_obj.data.get("title", package_title)
			package_category = json_obj.data.get("category", package_category)

	if file_list.has("project.ambmix"):
		var proj_bytes: PackedByteArray = reader.read_file("project.ambmix")
		project_json_str = proj_bytes.get_string_from_utf8()

	var slug: String = AmbientMixerClient.sanitize_filename(package_title)
	if slug.is_empty(): slug = "imported_soundscape"

	var dest_folder: String = get_library_root().path_join(slug)
	var suffix: int = 1
	while DirAccess.dir_exists_absolute(dest_folder):
		dest_folder = get_library_root().path_join("%s_%d" % [slug, suffix])
		suffix += 1

	DirAccess.make_dir_recursive_absolute(dest_folder)

	# Extract all files safely
	for f_name in file_list:
		# Path traversal guard
		if f_name.contains("..") or f_name.begins_with("/") or f_name.begins_with("\\"):
			continue

		var out_path: String = dest_folder.path_join(f_name)
		if f_name.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(out_path)
		else:
			var base_dir: String = out_path.get_base_dir()
			if not DirAccess.dir_exists_absolute(base_dir):
				DirAccess.make_dir_recursive_absolute(base_dir)

			var bytes: PackedByteArray = reader.read_file(f_name)
			var f_out: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
			if f_out != null:
				f_out.store_buffer(bytes)
				f_out.close()

	reader.close()

	# Remap paths in project.ambmix to absolute extracted paths
	var proj_path: String = dest_folder.path_join("project.ambmix")
	var project: SoundscapeData.SoundscapeProject = null

	if FileAccess.file_exists(proj_path):
		var f_p: FileAccess = FileAccess.open(proj_path, FileAccess.READ)
		if f_p != null:
			var json_obj: JSON = JSON.new()
			if json_obj.parse(f_p.get_as_text()) == OK and json_obj.data is Dictionary:
				var dict: Dictionary = json_obj.data
				var tracks_arr: Array = dict.get("tracks", [])
				for t_dict in tracks_arr:
					if t_dict is Dictionary:
						var rel_file: String = t_dict.get("file_path", "")
						if not rel_file.is_empty():
							var full_stem: String = dest_folder.path_join(rel_file)
							if FileAccess.file_exists(full_stem):
								t_dict["file_path"] = full_stem
							elif FileAccess.file_exists(dest_folder.path_join("audio").path_join(rel_file.get_file())):
								t_dict["file_path"] = dest_folder.path_join("audio").path_join(rel_file.get_file())
							elif FileAccess.file_exists(dest_folder.path_join(rel_file.get_file())):
								t_dict["file_path"] = dest_folder.path_join(rel_file.get_file())

				var cov_rel: String = dict.get("cover_image_path", "")
				if not cov_rel.is_empty():
					var full_cov: String = dest_folder.path_join(cov_rel)
					if FileAccess.file_exists(full_cov):
						dict["cover_image_path"] = full_cov

				project = SoundscapeData.SoundscapeProject.from_dict(dict)
				project.source_path = proj_path
			f_p.close()

		if project != null:
			project.save_to_file(proj_path)

	# Register category if new
	if not package_category.is_empty():
		_register_category_if_new(package_category)

	print("✔ Successfully imported Soundscape Package into: ", dest_folder)
	return project

static func _register_category_if_new(new_cat: String) -> void:
	var cat_file: String = AppPaths.get_soundscape_categories_file()
	var cats: Array[String] = ["ALL", "Nature", "Weather", "Ambient", "Relaxation", "Fantasy", "Sci-Fi", "Custom"]
	if FileAccess.file_exists(cat_file):
		var f: FileAccess = FileAccess.open(cat_file, FileAccess.READ)
		if f != null:
			var json: JSON = JSON.new()
			if json.parse(f.get_as_text()) == OK and json.data is Array:
				cats.clear()
				for c in json.data:
					cats.append(str(c))
			f.close()

	if not cats.has(new_cat):
		cats.append(new_cat)
		var fw: FileAccess = FileAccess.open(cat_file, FileAccess.WRITE)
		if fw != null:
			fw.store_string(JSON.stringify(cats, "\t"))
			fw.close()
