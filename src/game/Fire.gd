extends Area2D

var travel_vector = Vector2.ZERO : set = _set_travel_vector
var burning_bodies := []

@onready var animation_tree = $AnimationTree


func _set_travel_vector(value):
	travel_vector = value
	if travel_vector.x == 0 or travel_vector.y == 0:
		call_deferred("_set_animation")


func _set_animation() -> void:
	animation_tree.active = true
	animation_tree.set("parameters/blend_position", travel_vector)


func _on_Timer_timeout():
	for body in burning_bodies:
		if body != null and body.has_method("burning_finished"):
			body.burning_finished(global_position)
	queue_free()


func _on_Fire_body_entered(body):
	if body.has_method("explode"):
		burning_bodies.append(body)
		body.explode(global_position)


func create_sync_data() -> Dictionary:
	return {
		position = global_position,
		travel_vector = travel_vector
	}
