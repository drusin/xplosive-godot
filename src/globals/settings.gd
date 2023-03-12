extends Node

var values := {
	alias = "New Player",
	lobby_name = "Xplosive!",
	lobby_password = ""
}

func save_settings() -> void:
	var file = FileAccess.open(Constants.SETTINGS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(values))


func load_settings() -> void:
	if FileAccess.file_exists(Constants.SETTINGS_FILE):
		var file = FileAccess.open(Constants.SETTINGS_FILE, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		_merge_settings(test_json_conv.get_data())


func _merge_settings(loaded: Dictionary) -> void:
	for key in loaded:
		values[key] = loaded[key]


func delete_settings() -> void:
	var dir = DirAccess.open(Constants.SETTINGS_FILE)
	dir.remove(Constants.SETTINGS_FILE)
