extends CharacterBody2D
class_name Player

const LAYERS := {
	1: 2,
	2: 3,
	3: 4,
	4: 5,
}

@export_range(1, 4) var player_number := 1
@export var SPEED := 20
@export var max_bombs := 2
@export var power := 2

@onready var animation_tree := $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var bomb_detector := $BombDetector
@onready var controller := $Controller
@onready var current_bombs := max_bombs


func _ready() -> void:
	set_collision_mask_value(LAYERS[player_number], true)
	animation_tree.active = true


func _physics_process(_delta) -> void:
	if controller.direction != Vector2.ZERO:
		animation_tree.set('parameters/Run/blend_position', controller.direction)
		animation_state.travel('Run')
	else:
		animation_state.travel('Idle')
	
	velocity = controller.direction * SPEED
	move_and_slide()


func is_on_bomb() -> bool:
	return bomb_detector.get_overlapping_bodies().size() != 0


func _death_anim_finished() -> void:
	queue_free()


func explode(_position) -> void:
	die()


@rpc("call_local")
func die() -> void:
	animation_state.travel("Dead")
	set_process(false)
	set_physics_process(false)
	controller.set_process(false)

