tool
extends KinematicBody2D

enum PlayerColor { Blue, Green, Purple, Red }
const LAYERS = {
	PlayerColor.Blue: 2,
	PlayerColor.Green: 3,
	PlayerColor.Purple: 4,
	PlayerColor.Red: 5
}

const Bomb = preload("res://src/Bomb.tscn")

export (PlayerColor)var player_color = PlayerColor.Blue
export var SPEED = 20
export var max_bombs = 2
export var power = 2

var velocity = Vector2.ZERO
var dead = false

onready var player_color_str = PlayerColor.keys()[player_color]
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var bomb_detector = $BombDetector
onready var controller = $Controller
onready var current_bombs = max_bombs

func _ready():
	set_collision_mask_bit(LAYERS[player_color], true)
	for i in PlayerColor:
		get_node(i).visible = i == player_color_str
	if not Engine.editor_hint:
		animation_tree.anim_player = get_node(player_color_str + "/AnimationPlayer").get_path()
		animation_tree.active = true


func _physics_process(_delta):
	if Engine.editor_hint or dead: return
	
	if controller.movement != Vector2.ZERO:
		animation_tree.set('parameters/Run/blend_position', controller.movement)
		animation_state.travel('Run')
	else:
		animation_state.travel('Idle')
	
	velocity = controller.movement * SPEED
	velocity = move_and_slide(velocity)


func is_on_bomb():
	return bomb_detector.get_overlapping_bodies().size() != 0


func _death_anim_finished():
	queue_free()
	
	
func explode(_position, _timeout):
	animation_state.travel("Dead")
	dead = true
