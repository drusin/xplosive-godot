extends Node

const TRANSITION_DURATION = 0.5

export (NodePath)var main_menu_path
export (NodePath)var logo_path

var history = []

onready var logo = get_node(logo_path)
onready var current = get_node(main_menu_path)
onready var tween = $Tween


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
	tween.interpolate_property(current, "rect_position", null, Vector2(-64, initial_left.y), TRANSITION_DURATION)
	tween.interpolate_callback(self, TRANSITION_DURATION, "_after_transition", current)
	
	to.on_show()
	to.visible = true
	to.rect_position.x = 64
	var initial_right = to.rect_position
	tween.interpolate_property(to, "rect_position", null, Vector2(0, initial_right.y), TRANSITION_DURATION)
	
	if !current.fullscreen and to.fullscreen:
		_transition_logo_to_left()
	elif current.fullscreen and !to.fullscreen:
		_transition_logo_from_right()
		
	tween.start()


func _transition_logo_to_left():
	var initial_pos = logo.rect_position
	tween.interpolate_property(logo, "rect_position", null, Vector2(-64, initial_pos.y), TRANSITION_DURATION)


func _transition_logo_from_right():
	var initial_pos = logo.rect_position
	tween.interpolate_property(logo, "rect_position", null, Vector2(-64, initial_pos.y), TRANSITION_DURATION)


func _transition_right(to):
	to.on_show()
	to.visible = true
	to.rect_position.x = -64
	var initial_left = to.rect_position
	tween.interpolate_property(to, "rect_position", null, Vector2(0, initial_left.y), TRANSITION_DURATION)
	
	var initial_right = current.rect_position
	tween.interpolate_property(current, "rect_position", null, Vector2(64, initial_right.y), TRANSITION_DURATION)
	tween.interpolate_callback(self, TRANSITION_DURATION, "_after_transition", current)
	
	if !current.fullscreen and to.fullscreen:
		_transition_logo_to_right()
	elif current.fullscreen and !to.fullscreen:
		_transition_logo_from_left()
	
	tween.start()


func _transition_logo_to_right():
	var initial_pos = logo.rect_position
	tween.interpolate_property(logo, "rect_position", null, Vector2(64, initial_pos.y), TRANSITION_DURATION)


func _transition_logo_from_left():
	var initial_pos = logo.rect_position
	tween.interpolate_property(logo, "rect_position", null, Vector2(0, initial_pos.y), TRANSITION_DURATION)


func _after_transition(old):
	old.visible = false
	_enable_input()
	current.call_deferred("focus_default")
	old.on_hide()


func _disable_input():
	get_tree().get_root().set_disable_input(true)
	
	
func _enable_input():
	get_tree().get_root().set_disable_input(false)
