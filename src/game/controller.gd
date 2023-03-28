extends Node

signal bomb_pressed(player)

@export var direction := Vector2.ZERO

@onready var player := get_parent()


func _ready() -> void:
	# disable processing if not a local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


func _process(_delta) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_action_just_pressed("ui_accept"):
		emit_bomb_pressed.rpc()


@rpc("call_local")
func emit_bomb_pressed() -> void:
	emit_signal("bomb_pressed", player)
