extends StaticBody2D

const BITS_TO_CHECK = [2, 3, 4, 5]
const FireController = preload("res://src/FireController.tscn")

export var power = 2

var overlap_set = false

onready var player_detector = $PlayerDetector
onready var sprite = $AnimatedSprite


func _ready():
	sprite.playing = true


func _physics_process(_delta):
	if overlap_set or player_detector.get_overlapping_bodies().size() == 0:
		return;

	for body in player_detector.get_overlapping_bodies():
		for bit in BITS_TO_CHECK:
			if body.get_collision_mask_bit(bit):
				set_collision_layer_bit(bit, false)
				
	overlap_set = true


func _on_Area2D_body_exited(body):
	for bit in BITS_TO_CHECK:
		if body.get_collision_mask_bit(bit):
			set_collision_layer_bit(bit, true)


func _on_AnimatedSprite_animation_finished():
	var fire_controller = FireController.instance()
	fire_controller.global_position = global_position
	fire_controller.power = power
	get_parent().add_child(fire_controller)
	queue_free()
	
	
func _on_explosion(_position, _timeout):
	_on_AnimatedSprite_animation_finished()
