extends AbstractMenu

onready var create_button = $CenterContainer/GridContainer/Create


func focus_default():
	create_button.grab_focus()


func _on_Create_pressed():
	emit_signal("transition", "CreateMenu")


func _on_Join_pressed():
	emit_signal("transition", "JoinMenu")


func _on_Back_pressed():
	SignalingClient.disconnect_from_host()
	MultiplayerState.online = false
	emit_signal("transition_back")
