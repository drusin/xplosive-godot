extends HBoxContainer

onready var avatar_texture = $Avatar
onready var change_avatar = $ChangeAvatar
onready var name_label = $Name
onready var name_edit = $NameEdit


func setup(player):
	visible = true
	set_color(player.player_color)
	name_label.text = player.alias
	name_edit.text = player.alias
	if player.id == multiplayer.get_network_unique_id():
		change_avatar.visible = true
		name_edit.visible = true
		name_label.visible = false
	else:
		change_avatar.visible = false
		name_edit.visible = false
		name_label.visible = true


func set_color(color):
	avatar_texture.texture.region.position.x = color * 160


func _on_ChangeAvatar_pressed():
	multiplayer.send_bytes(MultiplayerState.players[multiplayer.get_network_unique_id()].alias.to_utf8())
