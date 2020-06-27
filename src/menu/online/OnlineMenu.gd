extends AbstractMenu

onready var create_button = $CenterContainer/GridContainer/Create


func focus_default():
	create_button.grab_focus()


func _on_Back_pressed():
	emit_signal("transition_back")


func _on_Create_pressed():
	emit_signal("transition", "CreateMenu")
