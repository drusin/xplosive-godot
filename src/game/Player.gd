extends KinematicBody2D

const LAYERS := {
	1: 2,
	2: 3,
	3: 4,
	4: 5,
}

export (int, 1, 4) var player_number := 1
export var SPEED := 20
export var max_bombs := 2
export var power := 2

var velocity := Vector2.ZERO
var dead := false

onready var animation_tree := $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var bomb_detector := $BombDetector
onready var controller := $Controller
onready var current_bombs := max_bombs


func _ready() -> void:
	set_collision_mask_bit(LAYERS[player_number], true)
	animation_tree.active = true


func _physics_process(_delta) -> void:
	if dead: return
	
	if controller.movement != Vector2.ZERO:
		animation_tree.set('parameters/Run/blend_position', controller.movement)
		animation_state.travel('Run')
	else:
		animation_state.travel('Idle')
	
	velocity = controller.movement * SPEED
	velocity = move_and_slide(velocity)


func is_on_bomb() -> bool:
	return bomb_detector.get_overlapping_bodies().size() != 0


func _death_anim_finished() -> void:
	queue_free()


func explode(_position, _timeout) -> void:
	animation_state.travel("Dead")
	dead = true
