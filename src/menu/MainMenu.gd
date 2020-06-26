extends MarginContainer

signal transition(to)

onready var local_button = $CenterContainer/GridContainer/Local


func focus_default():
	local_button.grab_focus()


func _on_Local_pressed():
	emit_signal("transition", "local_menu")


func _on_Online_pressed():
	pass # Replace with function body.


func _on_Settings_pressed():
	pass # Replace with function body.
