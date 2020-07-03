extends AbstractMenu

onready var create_button = $CenterContainer/GridContainer/Create
onready var name_edit = $CenterContainer/GridContainer/NameEdit
onready var password_edit = $CenterContainer/GridContainer/PasswordEdit


func _ready():
	fullscreen = true


func focus_default():
	create_button.grab_focus()


func _on_Create_pressed():
	SignalingClient.create_lobby(name_edit.text, password_edit.text, Constants.MAX_PLAYERS)
	emit_signal("transition", "Lobby")


func _on_Back_pressed():
	emit_signal("transition_back")

