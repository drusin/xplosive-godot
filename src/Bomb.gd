extends StaticBody2D

const BITS_TO_CHECK = [2, 3, 4, 5]

export var force = 2

var overlap_set = false

onready var overlap_detector = $Area2D
onready var sprite = $AnimatedSprite


# func _ready():
# 	sprite.playing = true


func _physics_process(_delta):
	if overlap_set or overlap_detector.get_overlapping_bodies().size() == 0:
		return;

	for bit in BITS_TO_CHECK:
		set_collision_layer_bit(bit, true)

	for body in overlap_detector.get_overlapping_bodies():
		for bit in BITS_TO_CHECK:
			if body.get_collision_mask_bit(bit):
				set_collision_layer_bit(bit, false)
				
	overlap_set = true


func _on_Area2D_body_exited(body):
	for bit in BITS_TO_CHECK:
		if body.get_collision_mask_bit(bit):
			set_collision_layer_bit(bit, true)


func _on_AnimatedSprite_animation_finished():
	queue_free()
