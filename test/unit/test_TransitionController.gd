extends "res://addons/gut/test.gd"

var TransitionController = load("res://src/menu/TransitionController.gd")

var controller
var logo
var tween
var current


func before_all():
	logo = new_node()


func before_each():
	controller = TransitionController.new()
	current = new_node()
	controller.current = current
	controller.logo = logo
	tween = double(Tween).new()
	controller.tween = tween
	controller._input_disabler = Viewport.new()


func after_each():
	for node in controller.history:
		node.free()
	controller.tween.free()
	controller._input_disabler.free()
	controller.free()


func after_all():
	logo.free()


static func new_node(fullscreen = false):
	var node = AbstractMenu.new()
	node.fullscreen = fullscreen
	return node


func test_small_to_small_forward():
	var to = new_node()
	controller.transition(to)
	assert_called(tween, "interpolate_property", [current, "rect_position", Vector2(0, 0), Vector2(-64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [to, "rect_position", Vector2(64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])


func test_small_to_small_backward():
	var to = new_node()
	controller.history.append(to)
	controller.transition_back()
	assert_called(tween, "interpolate_property", [current, "rect_position", Vector2(0, 0), Vector2(64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [to, "rect_position", Vector2(-64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	

func test_small_to_fullscreen_forward():
	var to = new_node(true)
	controller.transition(to)
	assert_called(tween, "interpolate_property", [current, "rect_position", Vector2(0, 0), Vector2(-64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [to, "rect_position", Vector2(64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [logo, "rect_position", Vector2(0, 0), Vector2(-64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])


func test_small_to_fullscreen_backward():
	var to = new_node(true)
	controller.history.append(to)
	controller.transition_back()
	assert_called(tween, "interpolate_property", [current, "rect_position", Vector2(0, 0), Vector2(64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [to, "rect_position", Vector2(-64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [logo, "rect_position", Vector2(0, 0), Vector2(64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	
	
func test_fullscreen_to_small_forward():
	current.fullscreen = true
	var to = new_node()
	controller.transition(to)
	assert_called(tween, "interpolate_property", [current, "rect_position", Vector2(0, 0), Vector2(-64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [to, "rect_position", Vector2(64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [logo, "rect_position", Vector2(64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	

func test_fullscreen_to_small_backward():
	current.fullscreen = true
	var to = new_node()
	controller.history.append(to)
	controller.transition_back()
	assert_called(tween, "interpolate_property", [current, "rect_position", Vector2(0, 0), Vector2(64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [to, "rect_position", Vector2(-64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [logo, "rect_position", Vector2(-64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	

func test_fullscreen_to_fullscreen_forward():
	controller.current.fullscreen = true
	var to = new_node(true)
	controller.transition(to)
	assert_called(tween, "interpolate_property", [current, "rect_position", Vector2(0, 0), Vector2(-64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [to, "rect_position", Vector2(64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_call_count(tween, "interpolate_property", 2)


func test_fullscreen_to_fullscreen_backward():
	controller.current.fullscreen = true
	var to = new_node(true)
	controller.history.append(to)
	controller.transition_back()
	assert_called(tween, "interpolate_property", [current, "rect_position", Vector2(0, 0), Vector2(64, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_called(tween, "interpolate_property", [to, "rect_position", Vector2(-64, 0), Vector2(0, 0), Constants.TRANSITION_DURATION, 0, 2, 0])
	assert_call_count(tween, "interpolate_property", 2)
