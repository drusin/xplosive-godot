extends StaticBody2D

signal exploded(player)

const BITS_TO_CHECK := [2, 3, 4, 5]

@export var power := 2
@export var FireController := preload("res://src/game/FireController.tscn")

var player: Player
var checked_for_players := false
var fire_container: Node
var fire_controller_container: Node

@onready var player_detector := $PlayerDetector
@onready var sprite := $AnimatedSprite2D


func _ready() -> void:
	if fire_container == null:
		fire_container = get_parent()
	if fire_controller_container == null:
		fire_controller_container = get_parent()
	
	sprite.play()


func _physics_process(_delta) -> void:
	if player_detector.get_overlapping_bodies().size() == 0 and !checked_for_players:
		# we have to wait one tick for the player_detector to work :/
		checked_for_players = true
		return;
	
	for bit in BITS_TO_CHECK:
		set_collision_layer_value(bit, true)
	
	for body in player_detector.get_overlapping_bodies():
		for bit in BITS_TO_CHECK:
			if body.get_collision_mask_value(bit):
				set_collision_layer_value(bit, false)
	
	set_physics_process(false)


func _on_Area2D_body_exited(body):
	for bit in BITS_TO_CHECK:
		if body.get_collision_mask_value(bit):
			set_collision_layer_value(bit, true)


func _on_AnimatedSprite_animation_finished():
	explode(global_position)


func explode(_position):
	var fire_controller = FireController.instantiate()
	fire_controller.global_position = global_position
	fire_controller.power = power
	fire_controller.fire_container = fire_container
	fire_controller_container.add_child(fire_controller)
	emit_signal("exploded", player)
	queue_free()
