extends Node

const BOMB = "Bomb"
const FIRE = "Fire"

var accumulator := 0.0

@export (NodePath)var players_path
@export (NodePath)var tile_map_path
@export (NodePath)var bomb_controller_path

@onready var players := get_node(players_path)
@onready var tile_map := get_node(tile_map_path)
@onready var bomb_controller := get_node(bomb_controller_path)


func _process(delta):
	if !MultiplayerState.online or !get_tree().is_server():
		set_process(false)
		return
	
	accumulator += delta
	
	if (accumulator >= Constants.SYNC_RATE):
		_do_sync()
		accumulator -= Constants.SYNC_RATE


func _do_sync() -> void:
	print("syncing")
	
	for player in players.get_children():
		player.rpc("synchronize", player.create_sync_data())
	
	tile_map.rpc("synchronize", tile_map.create_sync_data())
	
	bomb_controller.rpc("synchronize", bomb_controller.create_sync_data())


func _sync_bomb_controller() -> void:
	var bombs := []
	var fires := []
	for bomb in bomb_controller.bomb_container.get_children():
		bombs.append(_read_bomb_data(bomb))
	for fire in bomb_controller.fire_container.get_children():
		fires.append(_read_fire_data(fire))
	
	bomb_controller.rpc("synchronize", bombs, fires)


func _read_bomb_data(bomb) -> Dictionary:
	return {
		player_name = bomb.player.get_name(),
		position = bomb.global_position
	}


func _read_fire_data(fire) -> Dictionary:
	return {
		position = fire.global_position,
		travel_vector = fire.travel_vector
	}
