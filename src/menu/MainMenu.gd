extends AbstractMenu

onready var local_button = $CenterContainer/GridContainer/Local


func focus_default():
	local_button.grab_focus()


func _on_Local_pressed():
	emit_signal("transition", "LocalMenu")


func _on_Online_pressed():
	SignalingClient.connect_to(Constants.SIGNALING_URL, Settings.values.alias)
	emit_signal("transition", "OnlineMenu")


func _on_Settings_pressed():
	emit_signal("transition", "MultiplayerSettings")
