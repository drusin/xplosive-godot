extends Node

signal lobby_updated()

var online = false

var lobby = {
	id = 1234567,
	name = "Awesome lobby",
	has_password = false
}

var players = {
	1: {
		id = 1,
		alias = "Player 1",
		player_color = Constants.PlayerColor.Blue
	},
	123456: {
		id = 123456,
		alias = "Player 2",
		player_color = Constants.PlayerColor.Green
	}
}


func _ready():
# warning-ignore:return_value_discarded
	SignalingClient.connect("lobby_update_recieved", self, "update_lobby")
	

func update_lobby(_lobby):
	lobby.id = _lobby.id
	lobby.name = _lobby.name
	lobby.has_password = _lobby.has_password
	
	var players_tmp = {}
	for lobby_player in _lobby.players:
		var player = {} if !players.has(lobby_player.id) else players[int(lobby_player.id)]
		player.id = lobby_player.id
		player.alias = lobby_player.alias
		player.peer = get_tree().multiplayer.network_peer
		player.player_color = 1
		players_tmp[int(lobby_player.id)] = player;
	
	players = players_tmp
	emit_signal("lobby_updated")
