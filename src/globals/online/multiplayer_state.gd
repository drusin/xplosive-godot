extends Node

signal lobby_updated()

var online := false : set = _set_online
func _set_online(new_var: bool) -> void:
	push_error("Don't set 'MultiplayerState.online' from outside!")
	online = new_var


var lobby := {
	id = 1234567,
	name = "Awesome lobby",
	has_password = false,
	max_players = 4
}

var players := {
	1: {
		id = 1,
		alias = "Player 1",
		number = 1
	},
	123456: {
		id = 123456,
		alias = "Player 2",
		number = 2
	}
}


func _ready() -> void:
# warning-ignore:return_value_discarded
	SIGNALING_CLIENT.connect("lobby_update_recieved",Callable(self,"update_lobby"))
# warning-ignore:return_value_discarded
	SIGNALING_CLIENT.connect("connection_established",Callable(self,"_on_signaling_established"))
# warning-ignore:return_value_discarded
	SIGNALING_CLIENT.connect("connection_closed",Callable(self,"_on_signaling_closed"))


func _on_signaling_established() -> void:
	online = true


func _on_signaling_closed() -> void:
	online = false


func update_lobby(update: Dictionary) -> void:
	lobby.id = update.id
	lobby.name = update.name
	lobby.has_password = update.has_password
	lobby.max_players = update.max_players
	
	var players_tmp := {}
	var i := 1
	for lobby_player in update.players:
		var player_id = int(lobby_player.id)
		var player = {} if !players.has(player_id) else players[player_id]
		player.id = lobby_player.id
		player.alias = lobby_player.alias
		player.peer = get_tree().multiplayer.network_peer
		player.number = i
		players_tmp[player_id] = player;
		i += 1
	
	players = players_tmp
	emit_signal("lobby_updated")
