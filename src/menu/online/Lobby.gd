extends AbstractMenu

var lobby_id := -1

onready var lobby_name_label = $VBoxContainer/MarginContainer/LobbyName
onready var lobby_name_edit = $VBoxContainer/MarginContainer/LobbyNameEdit
onready var player_container = $VBoxContainer
onready var start_button = $VBoxContainer/MarginContainer2/HBoxContainer5/Start
onready var back_button = $VBoxContainer/MarginContainer2/HBoxContainer5/Back
onready var players = [
	$VBoxContainer/Player1,
	$VBoxContainer/Player2,
	$VBoxContainer/Player3,
	$VBoxContainer/Player4
]

func _ready():
	fullscreen = true
# warning-ignore:return_value_discarded
	MultiplayerState.connect("lobby_updated", self, "update_lobby")
# warning-ignore:return_value_discarded
	SignalingClient.connect("lobby_deleted", self, "_on_lobby_deleted")
# warning-ignore:return_value_discarded
	multiplayer.connect("network_peer_packet", self, "_print_message")


func _print_message(id, message : PoolByteArray):
	print("message from ", id)
	print(message.get_string_from_utf8())


func focus_default():
	if get_tree().is_network_server():
		start_button.grab_focus() 
	else:
		back_button.grab_focus()


func update_lobby():
	lobby_id = MultiplayerState.lobby.id
	lobby_name_label.text = MultiplayerState.lobby.name
	lobby_name_edit.text = MultiplayerState.lobby.name
	
	if get_tree().is_network_server():
		lobby_name_label.visible = false
		lobby_name_edit.visible = true
		start_button.visible = true
	else:
		lobby_name_label.visible = true
		lobby_name_edit.visible = false
		start_button.visible = false
	
	for player in players:
		player.visible = false
	
	var i = 0
	for player in MultiplayerState.players.values():
		players[i].setup(player, i)
		i += 1


func _on_lobby_deleted(_lobby_id):
	if _lobby_id == lobby_id:
		_leave_lobby()


func _on_Back_pressed():
	_leave_lobby()


func _leave_lobby():
	SignalingClient.disconnect_all_peers()
	lobby_id = -1
	emit_signal("transition_back")
	if get_tree().is_network_server():
		SignalingClient.delete_lobby()
	else:
		SignalingClient.leave_lobby()
