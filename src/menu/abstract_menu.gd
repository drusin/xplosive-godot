extends Control
class_name AbstractMenu

# warning-ignore:unused_signal
signal transition(to)
# warning-ignore:unused_signal
signal transition_back()

var fullscreen = false


func focus_default():
	print("You have to override 'focus_default'!")