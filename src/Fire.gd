extends Area2D

var travel_vector = Vector2.ZERO setget _set_travel_vector

onready var animation_tree = $AnimationTree
onready var burn_time = $Timer.wait_time


func _set_travel_vector(value):
	travel_vector = value
	if travel_vector.x == 0 or travel_vector.y == 0:
		animation_tree.active = true
		animation_tree.set("parameters/blend_position", travel_vector)


func _on_Timer_timeout():
	queue_free()


func _on_Fire_body_entered(body):
	if body.has_method("explode"):
		 body.explode(global_position, burn_time)
