extends Node

const DURATION := Constants.TRANSITION_DURATION

export (NodePath)var main_menu_path
export (NodePath)var logo_path

var history := []

onready var logo := get_node(logo_path)
onready var current := get_node(main_menu_path)
onready var tween := $Tween


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
	var initial_left = current.rect_position
	tween.interpolate_property(current, "rect_position", null, Vector2(-64, initial_left.y), DURATION)
	tween.interpolate_callback(self, DURATION, "_after_transition", current)
	
	to.on_show()
	to.visible = true
	to.rect_position.x = 64
	var initial_right = to.rect_position
	tween.interpolate_property(to, "rect_position", null, Vector2(0, initial_right.y), DURATION)
	
	if !current.fullscreen and to.fullscreen:
		_transition_logo_to_left()
	elif current.fullscreen and !to.fullscreen:
		_transition_logo_from_right()
		
	tween.start()


func _transition_logo_to_left() -> void:
	var initial_pos = logo.rect_position
	tween.interpolate_property(logo, "rect_position", null, Vector2(-64, initial_pos.y), DURATION)


func _transition_logo_from_right() -> void:
	var initial_pos = logo.rect_position
	tween.interpolate_property(logo, "rect_position", null, Vector2(0, initial_pos.y), DURATION)


func _transition_right(to: Node) -> void:
	to.on_show()
	to.visible = true
	to.rect_position.x = -64
	var initial_left = to.rect_position
	tween.interpolate_property(to, "rect_position", null, Vector2(0, initial_left.y), DURATION)
	
	var initial_right = current.rect_position
	tween.interpolate_property(current, "rect_position", null, Vector2(64, initial_right.y), DURATION)
	tween.interpolate_callback(self, DURATION, "_after_transition", current)
	
	if !current.fullscreen and to.fullscreen:
		_transition_logo_to_right()
	elif current.fullscreen and !to.fullscreen:
		_transition_logo_from_left()
	
	tween.start()


func _transition_logo_to_right() -> void:
	var initial_pos = logo.rect_position
	tween.interpolate_property(logo, "rect_position", null, Vector2(64, initial_pos.y), DURATION)


func _transition_logo_from_left() -> void:
	var initial_pos = logo.rect_position
	tween.interpolate_property(logo, "rect_position", null, Vector2(0, initial_pos.y), DURATION)


func _after_transition(old: Node) -> void:
	old.visible = false
	_enable_input()
	current.call_deferred("focus_default")
	old.on_hide()


func _disable_input() -> void:
	get_tree().get_root().set_disable_input(true)


func _enable_input() -> void:
	get_tree().get_root().set_disable_input(false)
