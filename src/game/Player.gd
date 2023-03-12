extends CharacterBody2D
class_name Player

const LAYERS := {
	1: 2,
	2: 3,
	3: 4,
	4: 5,
}

@export (int, 1, 4) var player_number := 1
@export var SPEED := 20
@export var max_bombs := 2
@export var power := 2

var velocity := Vector2.ZERO
var dead := false

@onready var animation_tree := $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var bomb_detector := $BombDetector
@onready var controller := $Controller
@onready var tween := $Tween
@onready var current_bombs := max_bombs


func _ready() -> void:
	set_collision_mask_value(LAYERS[player_number], true)
	animation_tree.active = true


func _physics_process(_delta) -> void:
	if dead: return
	
	if controller.movement != Vector2.ZERO:
		animation_tree.set('parameters/Run/blend_position', controller.movement)
		animation_state.travel('Run')
	else:
		animation_state.travel('Idle')
	
	velocity = controller.movement * SPEED
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity


func is_on_bomb() -> bool:
	return bomb_detector.get_overlapping_bodies().size() != 0


func _death_anim_finished() -> void:
	queue_free()


func explode(_position) -> void:
	if !MultiplayerState.online:
		die()
	elif get_tree().is_server():
		rpc("die")


@rpc("any_peer", "call_local") func die() -> void:
	animation_state.travel("Dead")
	dead = true


func create_sync_data() -> Dictionary:
	return {
		position = position,
		current_bombs = current_bombs,
		max_bombs = max_bombs,
		power = power
	}


@rpc func synchronize(sync_data: Dictionary) -> void:
	tween.interpolate_property(self, "position", null, sync_data.position, Constants.INTERPOLATION_DURATION)
	tween.start()
	current_bombs = sync_data.current_bombs
	max_bombs = sync_data.max_bombs
	power = sync_data.power
