extends AbstractMenu

onready var save_button = $GridContainer/HBoxContainer/Save
onready var host_settings = $GridContainer/Control/ScrollContainer/LobbyContainer/HostSettings
onready var lobby_name_edit = host_settings.get_node("LobbyName")
onready var lobby_password_edit = host_settings.get_node("LobbyPassword")
onready var player_name_edit = $GridContainer/Control/ScrollContainer/LobbyContainer/PlayerName

func _ready() -> void:
	fullscreen = true


func focus_default() -> void:
	save_button.grab_focus()


func on_show() -> void:
	host_settings.visible = get_tree().is_network_server()
	lobby_name_edit.text = Settings.values.lobby_name
	lobby_password_edit.text = Settings.values.lobby_password
	player_name_edit.text = Settings.values.alias


func _on_Save_pressed() -> void:
	Settings.values.alias = player_name_edit.text	
	SignalingClient.send_alias(player_name_edit.text)
	
	if get_tree().is_network_server():
		Settings.values.lobby_name = lobby_name_edit.text
		Settings.values.lobby_password = lobby_password_edit.text
		SignalingClient.edit_lobby(
				MultiplayerState.lobby.id,
				lobby_name_edit.text,
				lobby_password_edit.text,
				MultiplayerState.lobby.max_players)
				
	Settings.save_settings()
	emit_signal("transition_back")


func _on_Cancel_pressed() -> void:
	emit_signal("transition_back")
