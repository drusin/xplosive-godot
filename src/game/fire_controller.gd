extends Node2D

@export var power = 3

var fire_container

@onready var parent = get_parent()
@onready var Fire := preload("res://src/game/fire.tscn")
@onready var raycast: RayCast2D = $RayCast2D


func _ready():
	if fire_container == null:
		fire_container = get_parent()
	
	create_fire(global_position, Vector2(0, 0), global_position)
	
	one_direction("x", 1)
	one_direction("x", -1)
	one_direction("y", 1)
	one_direction("y", -1)
	
	queue_free()


func one_direction(x_or_y, negative_or_positive):
	for i in range(0, power):
		var fire_position = global_position
		var raycast_start = global_position
		raycast_start[x_or_y] += 8 * i * negative_or_positive
		fire_position[x_or_y] += 8 * (i + 1) * negative_or_positive
		var new_travel_vector = Vector2()
		new_travel_vector[x_or_y] = power * negative_or_positive - i * negative_or_positive
		create_fire(fire_position, new_travel_vector, raycast_start)
		if raycast.is_colliding():
			break


func create_fire(fire_position, travel_vector, raycast_start):
	var fire = Fire.instantiate()
	fire.global_position = fire_position
	fire_container.call_deferred("add_child", fire)
	fire.call_deferred("_set_travel_vector",travel_vector)
	raycast.global_position = raycast_start
	raycast.target_position = fire_position - raycast_start
	raycast.force_raycast_update()