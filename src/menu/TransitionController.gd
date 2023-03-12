extends Node

const DURATION := Constants.TRANSITION_DURATION

@export (NodePath)var main_menu_path
@export (NodePath)var logo_path

var history := []

@onready var logo := get_node(logo_path)
@onready var current := get_node(main_menu_path)

@onready var _input_disabler = get_tree().get_root()


func transition(to: Node) -> void:
	_disable_input()
	if history.size() > 0 and history.back() == to:
		history.pop_back()
		_transition_right(to)
	else:
		history.append(current)
		_transition_left(to)
	
	current = to


func transition_back() -> void:
	transition(history.back())


func _transition_left(to: Node) -> void:
	_transition_internal(to, -64, 64)


func _transition_right(to: Node) -> void:
	_transition_internal(to, 64, -64)


func _transition_internal(to: Node, current_end_x: float, to_start_x: float) -> void:
	to.position.x = to_start_x
	var current_y = current.position.y
	var to_y = to.position.y
	var tween := get_tree().create_tween()
	# warning-ignore:return_value_discarded
	tween.tween_property(current, "position", Vector2(current_end_x, current_y), DURATION)
	# warning-ignore:return_value_discarded
	tween.parallel().tween_property(to, "position", Vector2(0, to_y), DURATION)
	to.visible = true
	to.on_show()

	if !current.fullscreen and to.fullscreen:
		_transition_logo(0, current_end_x, tween)
	if current.fullscreen and !to.fullscreen:
		_transition_logo(to_start_x, 0, tween)
	
	# warning-ignore:return_value_discarded
	tween.tween_callback(Callable(self,"_after_transition").bind(current))


func _transition_logo(from_x: float, to_x: float, tween: Tween) -> void:
	logo.position.x = from_x
	var initial_y = logo.position.y
	# warning-ignore:return_value_discarded
	tween.parallel().tween_property(logo, "position", Vector2(to_x, initial_y), DURATION)


func _after_transition(old: Node) -> void:
	old.visible = false
	_enable_input()
	current.call_deferred("focus_default")
	old.on_hide()


func _disable_input() -> void:
	_input_disabler.set_disable_input(true)


func _enable_input() -> void:
	_input_disabler.set_disable_input(false)
