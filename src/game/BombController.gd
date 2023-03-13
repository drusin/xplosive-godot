extends Node2D

@export var Player: PackedScene
@export var Bomb: PackedScene
@export var Fire: PackedScene
@export var players_path: NodePath

var players: Node;

@onready var bomb_container = $Bombs
@onready var fire_container = $Fires
@onready var fire_controller_container = $FireControllers

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
# warning-ignore:return_value_discarded
	player.controller.connect("bomb_pressed",Callable(self,"_on_bomb_pressed"))



func _on_bomb_pressed(player: Player) -> void:
	if !player.dead and player.current_bombs > 0 and !player.is_on_bomb():
		player.current_bombs -= 1
# warning-ignore:return_value_discarded
		_create_bomb(player, player.global_position)


func _create_bomb(player, position: Vector2) -> Node:
	var bomb = Bomb.instantiate();
	bomb.player = player
	bomb.power = player.power
	bomb.fire_container = fire_container
	bomb.fire_controller_container = fire_controller_container
	bomb.connect("exploded",Callable(self,"_on_bomb_exploded"))
	bomb_container.add_child(bomb)
	bomb.global_position = position
	bomb.global_position.x = round((bomb.global_position.x + 4) / 8) * 8 - 4
	bomb.global_position.y = round((bomb.global_position.y + 4) / 8) * 8 - 4
	return bomb


func _on_bomb_exploded(player) -> void:
	if player != null:
		player.current_bombs += 1


func create_sync_data() -> Dictionary:
	var bombs := []
	var fires := []
	for bomb in bomb_container.get_children():
		bombs.append(bomb.create_sync_data())
	for fire in fire_container.get_children():
		fires.append(fire.create_sync_data())
	
	return { bombs = bombs, fires = fires }


@rpc func synchronize(data: Dictionary) -> void:
	for bomb in bomb_container.get_children():
		bomb.free()
	_create_bombs(data.bombs)
	for fire in fire_container.get_children():
		fire.free()
	_create_fires(data.fires)


func _create_bombs(bombs: Array) -> void:
	for bomb in bombs:
		var player
		for _player in players.get_children():
			if _player.get_name() == bomb.player_name:
				player = _player
		var new_bomb = _create_bomb(player, bomb.position)
		new_bomb.sprite.frame = bomb.frame


func _create_fires(fires: Array) -> void:
	for fire in fires:
		var instance = Fire.instantiate()
		instance.global_position = fire.position
		instance.travel_vector = fire.travel_vector
		fire_container.add_child(instance)
