extends Node

const TRANSITION_DURATION = 0.5

export (NodePath)var main_menu_path

var history = []

onready var current = get_node(main_menu_path)
onready var tween_left = $TweenLeft
onready var tween_right = $TweenRight


func transiton(to):
	_disable_input()
	if history.size() > 0 and history.back() == to:
		history.pop_back()
		_transition_right(to)
		current = to
	else:
		history.append(current)
		_transition_left(to)
		current = to
		
		
func transition_back():
	_disable_input()
	var to = history.pop_back()
	_transition_right(to)
	current = to


func _transition_left(to):
	var initial_left = current.rect_position
	tween_left.interpolate_property(current, "rect_position", null, Vector2(-64, initial_left.y), TRANSITION_DURATION)
	tween_left.interpolate_callback(self, TRANSITION_DURATION, "_after_transition", current)
	
	to.visible = true
	to.rect_position.x = 64
	var initial_right = to.rect_position
	tween_right.interpolate_property(to, "rect_position", null, Vector2(0, initial_right.y), TRANSITION_DURATION)

	tween_left.start()
	tween_right.start()


func _transition_right(to):
	to.visible = true
	to.rect_position.x = -64
	var initial_left = to.rect_position
	tween_left.interpolate_property(to, "rect_position", null, Vector2(0, initial_left.y), TRANSITION_DURATION)
	
	var initial_right = current.rect_position
	tween_right.interpolate_property(current, "rect_position", null, Vector2(64, initial_right.y), TRANSITION_DURATION)
	tween_right.interpolate_callback(self, TRANSITION_DURATION, "_after_transition", current)

	tween_left.start()
	tween_right.start()


func _after_transition(old):
	old.visible = false
	_enable_input()
	current.focus_default()


func _disable_input():
	get_tree().get_root().set_disable_input(true)
	
	
func _enable_input():
	get_tree().get_root().set_disable_input(false)
