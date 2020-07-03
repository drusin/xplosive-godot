extends Node2D

const Player = preload("res://src/Player.tscn")

onready var players = $Players
onready var bomb_controller = $BombController
onready var spawn_points = $SpawnPoints

func _ready():
	for child in players.get_children():
		child.free()
	
	var i = 0
	for lobby_player in MultiplayerState.players.values():
		var player = Player.instance()
		player.player_color = lobby_player.player_color
		var position = spawn_points.get_children()[i].global_position
		player.global_position = Vector2(position.x, position.y)
		players.add_child(player)
		i += 1
		
		if MultiplayerState.online:
			player.get_node("Controller").set_network_master(lobby_player.id)
			player.set_name(str(lobby_player.id))
	
	bomb_controller.init()