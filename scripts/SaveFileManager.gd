# Save and load the game using the text or binary resource format.
extends Resource
class_name SaveFileManager

@export var nodes_data: Dictionary = {}: set = _set_nodes_data

func write_save_file() -> void:
	ResourceSaver.save(self, get_save_file_path())

static func save_file_exists() -> bool:
	return ResourceLoader.exists(get_save_file_path())

static func load_save_file() -> Resource:
	var save_path := get_save_file_path()
	if ResourceLoader.exists(save_path):
		return ResourceLoader.load(save_path, "", 0)
	return null

static func get_save_file_path() -> String:
	# This check allows to save and load a text resource in debug builds and a binary resource in the released project.
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return Const.SAVE_FILE_BASE_PATH + extension

func _set_nodes_data(value):
	nodes_data = value
