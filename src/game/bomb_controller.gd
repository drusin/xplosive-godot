extends Node2D

@export var players_path: NodePath

var players: Node;

@onready var Player := preload("res://src/game/player.tscn")
@onready var Bomb := preload("res://src/game/bomb.tscn")
@onready var Fire := preload("res://src/game/fire.tscn")
@onready var bomb_container := $Bombs
@onready var fire_container := $Fires
@onready var fire_controller_container := $FireControllers

func _ready() -> void:
	_assure_players()


func _assure_players() -> void:
	if players_path.is_empty():
		print("Path3D to players is empty! Creating fake player for testing...")
		var area := Area2D.new()
		area.add_child(Player.instantiate())
		add_child(area)
		players_path = area.get_path()
		init()


func init() -> void:
	players = get_node(players_path)
	for player in players.get_children():
		call_deferred("_connect_to_controller", player)


func _connect_to_controller(player: Player) -> void:
	player.controller.bomb_pressed.connect(_on_bomb_pressed)



func _on_bomb_pressed(player: Player) -> void:
	if player.current_bombs > 0 and !player.is_on_bomb():
		player.current_bombs -= 1
		_create_bomb(player)


func _create_bomb(player) -> void:
	var bomb = Bomb.instantiate();
	bomb.player = player
	bomb.power = player.power
	bomb.fire_container = fire_container
	bomb.fire_controller_container = fire_controller_container
	bomb.exploded.connect(_on_bomb_exploded)
	bomb_container.add_child(bomb)
	bomb.global_position = player.global_position
	bomb.global_position.x = round((bomb.global_position.x + 4) / 8) * 8 - 4
	bomb.global_position.y = round((bomb.global_position.y + 4) / 8) * 8 - 4


func _on_bomb_exploded(player) -> void:
	if player != null:
		player.current_bombs += 1
