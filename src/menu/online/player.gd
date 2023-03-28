extends HBoxContainer

@onready var number_label := $Number
@onready var name_label := $Name


func setup(player_number: int, player: Dictionary) -> void:
	number_label.text = str(player_number)
	name_label.text = player.alias
