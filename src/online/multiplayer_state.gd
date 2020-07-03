extends Node

signal lobby_updated()

var lobby = {
	id = 1234567,
	name = "Awesome lobby",
	has_password = false
}

var players = {}


func _ready():
# warning-ignore:return_value_discarded
	SignalingClient.connect("lobby_update_recieved", self, "update_lobby")
	

func update_lobby(_lobby):
	lobby.id = _lobby.id
	lobby.name = _lobby.name
	lobby.has_password = _lobby.has_password
	
	for lobby_player in _lobby.players:
		if !players.has(lobby_player.id):
			players[int(lobby_player.id)] = {}
		var player = players[int(lobby_player.id)]
		player.id = lobby_player.id
		player.alias = lobby_player.alias
		player.peer = get_tree().multiplayer.network_peer
	
	emit_signal("lobby_updated")
