extends Control

onready var local_button = $MainMenu/CenterContainer/GridContainer/Local
onready var online_button = $MainMenu/CenterContainer/GridContainer/Online
onready var settings_button = $MainMenu/CenterContainer/GridContainer/Settings

func _ready():
	local_button.grab_focus()
