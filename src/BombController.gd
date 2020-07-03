extends Node2D

const Player = preload("res://src/Player.tscn")
const Bomb = preload("res://src/Bomb.tscn")

export (NodePath)var players_path

var players;

func _ready():
	_assure_players()


func init():
	players = get_node(players_path)
	for player in players.get_children():
		call_deferred("_connect_to_controller", player)


func _connect_to_controller(player):
	player.controller.connect("bomb_pressed", self, "_on_bomb_pressed")


func _assure_players():
	if players_path.is_empty():
		print("Path to players is empty! Creating fake player for testing...")
		var area = Area2D.new()
		area.add_child(Player.instance())
		add_child(area)
		players_path = area.get_path()
		init()


func _on_bomb_pressed(player):
	if player.current_bombs > 0 and !player.is_on_bomb():
		player.current_bombs -= 1
		var bomb = Bomb.instance();
		bomb.player = player
		bomb.power = player.power
		bomb.connect("exploded", self, "_on_bomb_exploded")
		add_child(bomb)
		bomb.global_position = player.global_position
		bomb.global_position.x = round((bomb.global_position.x + 4) / 8) * 8 - 4
		bomb.global_position.y = round((bomb.global_position.y + 4) / 8) * 8 - 4


func _on_bomb_exploded(player):
	player.current_bombs += 1
