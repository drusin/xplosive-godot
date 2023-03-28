extends AbstractMenu

const Player := preload("res://src/menu/online/player.tscn")

@export var Level: PackedScene

var lobby_id := -1

@onready var lobby_name_label := $VBoxContainer/MarginContainer/LobbyName
@onready var player_container := $VBoxContainer/Players
@onready var start_button := $VBoxContainer/MarginContainer2/HBoxContainer5/Start
@onready var back_button := $VBoxContainer/MarginContainer2/HBoxContainer5/Back


func _ready() -> void:
	fullscreen = true
# warning-ignore:return_value_discarded
	MultiplayerState.connect("lobby_updated",Callable(self,"update_lobby"))
# warning-ignore:return_value_discarded
	SIGNALING_CLIENT.connect("lobby_deleted",Callable(self,"_on_lobby_deleted"))
# warning-ignore:return_value_discarded
	multiplayer.connect("peer_packet",Callable(self,"_print_message"))


func _print_message(id, message : PackedByteArray):
	print("message from ", id)
	print(message.get_string_from_utf8())


func focus_default() -> void:
	if get_tree().is_server():
		start_button.grab_focus() 
	else:
		back_button.grab_focus()


func update_lobby() -> void:
	lobby_id = MultiplayerState.lobby.id
	lobby_name_label.text = MultiplayerState.lobby.name
	
	start_button.visible = get_tree().is_server()
	
	for player in player_container.get_children():
		player.queue_free()
	
	var i := 1
	for player in MultiplayerState.players.values():
		var player_ui = Player.instantiate()
		player_container.add_child(player_ui)
		player_ui.setup(i, player)
		i += 1


func _on_player_name_changed(text: String) -> void:
	SIGNALING_CLIENT.send_alias(text)


func _on_lobby_deleted(_lobby_id) -> void:
	if _lobby_id == lobby_id:
		_leave_lobby()


func _on_Back_pressed() -> void:
	_leave_lobby()


func _leave_lobby() -> void:
	SIGNALING_CLIENT.disconnect_all_peers()
	lobby_id = -1
	emit_signal("transition_back")
	if get_tree().is_server():
		SIGNALING_CLIENT.delete_lobby()
	else:
		SIGNALING_CLIENT.leave_lobby()


func _on_Start_pressed() -> void:
	rpc("start_game")


@rpc("any_peer", "call_local") func start_game() -> void:
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_packed(Level)


func _on_Options_pressed():
	emit_signal("transition", "MultiplayerSettings")
