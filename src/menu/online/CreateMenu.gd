extends AbstractMenu


func _ready():
	fullscreen = false


func _on_Back_pressed():
	emit_signal("transition_back")
