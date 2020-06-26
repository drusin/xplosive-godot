extends Node2D

const Fire = preload("res://src/Fire.tscn")

export var power = 3

onready var parent = get_parent()
onready var raycast = $RayCast2D


func _ready():
	create_fire(global_position, Vector2(power, power), global_position)
	
	one_direction("x", 1)
	one_direction("x", -1)
	one_direction("y", 1)
	one_direction("y", -1)
	
	queue_free()


func one_direction(x_or_y, negative_or_positive):
	for i in range(0, power):
		var position = global_position
		var raycast_start = global_position
		raycast_start[x_or_y] += 8 * i * negative_or_positive
		position[x_or_y] += 8 * (i + 1) * negative_or_positive
		var new_travel_vector = Vector2()
		new_travel_vector[x_or_y] = power * negative_or_positive - i * negative_or_positive
		create_fire(position, new_travel_vector, raycast_start)
		if raycast.is_colliding():
			break


func create_fire(position, travel_vector, raycast_start):
	var fire = Fire.instance()
	fire.global_position = position
	parent.call_deferred("add_child", fire)
	fire.call_deferred("_set_travel_vector",travel_vector)
	raycast.global_position = raycast_start
	raycast.cast_to = position - raycast_start
	raycast.force_raycast_update()
