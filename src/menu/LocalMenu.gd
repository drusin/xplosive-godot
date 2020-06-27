extends AbstractMenu

const Level = "res://src/Level.tscn"

onready var minus_button = $CenterContainer/GridContainer/MarginContainer2/Minus
onready var plus_button = $CenterContainer/GridContainer/MarginContainer/Plus
onready var start_button = $CenterContainer/GridContainer/GridContainer/Start
onready var tutorial_button = $CenterContainer/GridContainer/GridContainer/Tutorial
onready var back_button = $CenterContainer/GridContainer/GridContainer/Back


func _ready():
	start_button.focus_next = plus_button.get_path()
	plus_button.focus_previous = start_button.get_path()
	plus_button.focus_next = tutorial_button.get_path()
	tutorial_button.focus_previous = plus_button.get_path()
	tutorial_button.focus_neighbour_top = start_button.get_path()
	back_button.focus_next = minus_button.get_path()
	minus_button.focus_previous = back_button.get_path()


func focus_default():
	start_button.grab_focus()


func _on_Back_pressed():
	emit_signal("transition_back")


func _on_Start_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(Level)
