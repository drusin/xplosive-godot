extends Control

onready var transition_controller = $TransitionController

onready var main_menu = $MainMenu
onready var local_menu = $LocalMenu


func _ready():
	main_menu.focus_default()


func _on_transition(to):
	transition_controller.transiton(self[to])
