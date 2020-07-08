extends Node

signal bomb_pressed(player)

var movement = Vector2.ZERO

onready var player = get_parent()


func _process(_delta):
	if !multiplayer.has_network_peer() or is_network_master():
		movement.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		movement.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		movement = movement.normalized()
		
		if multiplayer.has_network_peer():
			rpc_unreliable("set_movement", movement)
	
		if Input.is_action_just_pressed("ui_accept"):
			emit_signal("bomb_pressed", player)
			if multiplayer.has_network_peer():
				rpc("emit_bomb_pressed")


puppet func set_movement(mov):
	movement = mov


puppet func emit_bomb_pressed():
	emit_signal("bomb_pressed", player)
