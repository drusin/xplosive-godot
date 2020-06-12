tool
extends KinematicBody2D

enum PlayerColor { Blue, Green, Purple, Red }
export (PlayerColor) var player_color

onready var player_color_str = PlayerColor.keys()[player_color]
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

var velocity = Vector2.ZERO
var dead = false


func _ready():
	for i in PlayerColor:
		get_node(i).visible = i == player_color_str
	if not Engine.editor_hint:
		animation_tree.anim_player = get_node(player_color_str + "/AnimationPlayer").get_path()
		animation_tree.active = true


func _physics_process(delta):
	if Engine.editor_hint: return
	if Input.is_action_just_pressed("ui_accept") or dead:
		animation_state.travel("Dead")
		dead = true
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
