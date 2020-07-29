extends Node

var values := {
	alias = "New Player",
	lobby_name = "Xplosive!",
	lobby_password = ""
}

func save_settings() -> void:
	var file = File.new()
	file.open(Constants.SETTINGS_FILE, File.WRITE)
	file.store_string(to_json(values))
	file.close()


func load_settings() -> void:
	var file = File.new()
	if file.file_exists(Constants.SETTINGS_FILE):
		file.open(Constants.SETTINGS_FILE, File.READ)
		_merge_settings(JSON.parse(file.get_as_text()).result)
	file.close()


func _merge_settings(loaded: Dictionary) -> void:
	for key in loaded:
		values[key] = loaded[key]


func delete_settings() -> void:
	var dir = Directory.new()
	dir.remove(Constants.SETTINGS_FILE)
