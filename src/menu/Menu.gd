extends Control

onready var transition_controller := $TransitionController

var submenus := {}

onready var menus := $Menus
onready var main_menu := $Menus/MainMenu


func _ready() -> void:
	Settings.load_settings()
	
	for menu in menus.get_children():
		menu.connect("transition", self, "_on_transition")
		menu.connect("transition_back", self, "_on_transition_back")
		submenus[menu.get_name()] = menu
	
	main_menu.focus_default()


func _on_transition(to) -> void:
	transition_controller.transition(submenus[to])


func _on_transition_back() -> void:
	transition_controller.transition_back()
