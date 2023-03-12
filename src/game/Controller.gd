extends Node

signal bomb_pressed(player)

var movement := Vector2.ZERO

@onready var player := get_parent()


func _process(_delta) -> void:
	if !multiplayer.has_multiplayer_peer() or is_multiplayer_authority():
		movement.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		movement.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		movement = movement.normalized()
		
		if multiplayer.has_multiplayer_peer():
			rpc("set_movement", movement)
	
		if Input.is_action_just_pressed("ui_accept"):
			emit_signal("bomb_pressed", player)
			if multiplayer.has_multiplayer_peer():
				rpc("emit_bomb_pressed")


@rpc func set_movement(mov: Vector2) -> void:
	movement = mov


@rpc func emit_bomb_pressed() -> void:
	emit_signal("bomb_pressed", player)
