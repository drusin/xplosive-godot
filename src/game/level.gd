extends Node2D

@export var Player: PackedScene

@onready var players = $Players
@onready var bomb_controller = $BombController
@onready var spawn_points = $SpawnPoints

func _ready():
	for child in players.get_children():
		child.free()
	
	var i := 0
	for lobby_player in MultiplayerState.players.values():
		var player = Player.instantiate()
		player.player_number = lobby_player.number
		var player_position = spawn_points.get_children()[i].global_position
		player.global_position = Vector2(player_position.x, player_position.y)
		
		if MultiplayerState.online:
			player.get_node("Controller").set_multiplayer_authority(lobby_player.id)
			player.set_name(str(lobby_player.id))
		
		players.add_child(player)
		i += 1
	
	bomb_controller.init()
