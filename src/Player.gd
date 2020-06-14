tool
extends KinematicBody2D

const Bomb = preload("res://src/Bomb.tscn")

enum PlayerColor { Blue, Green, Purple, Red }
const LAYERS = {
	PlayerColor.Blue: 2,
	PlayerColor.Green: 3,
	PlayerColor.Purple: 4,
	PlayerColor.Red: 5
}

export (PlayerColor) var player_color

var velocity = Vector2.ZERO
var dead = false

onready var player_color_str = PlayerColor.keys()[player_color]
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var bomb_container = get_node("/root/Level/Bombs")
onready var bomb_detector = $BombDetector

func _ready():
	set_collision_mask_bit(LAYERS[player_color], true)
	for i in PlayerColor:
		get_node(i).visible = i == player_color_str
	if not Engine.editor_hint:
		animation_tree.anim_player = get_node(player_color_str + "/AnimationPlayer").get_path()
		animation_tree.active = true


func _physics_process(delta):
	if Engine.editor_hint or dead: return
	if Input.is_action_just_pressed("ui_accept") and bomb_detector.get_overlapping_bodies().size() == 0:
		var bomb = Bomb.instance();
		bomb_container.add_child(bomb)
		bomb.global_position = global_position
		bomb.global_position.x = round((bomb.global_position.x + 4) / 8) * 8 - 4
		bomb.global_position.y = round((bomb.global_position.y + 4) / 8) * 8 - 4
		return

	var input_vector = Vector2()
	input_vector.x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
	input_vector.y = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		animation_tree.set('parameters/Run/blend_position', input_vector)
		animation_state.travel('Run')
	else:
		animation_state.travel('Idle')

	velocity = velocity.move_toward(input_vector * 10, 10)
	velocity = move_and_slide(velocity)


func _death_anim_finished():
	queue_free()
	
	
func _on_explosion(_position, _timeout):
	animation_state.travel("Dead")
	dead = true
