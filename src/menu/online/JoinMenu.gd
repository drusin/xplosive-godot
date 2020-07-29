extends AbstractMenu

const ICON_WIDTH := 5
const ICON_HEIGHT := 7
var ICONS := load("res://assets/lobby-icons/icons.png")

onready var back_button = $GridContainer/Back
onready var lobby_container = $GridContainer/Control/ScrollContainer/LobbyContainer


func _ready() -> void:
	fullscreen = true
# warning-ignore:return_value_discarded
	SignalingClient.connect("lobby_list_recieved", self, "update_lobbies")


func focus_default() -> void:
	back_button.grab_focus()


func update_lobbies(lobbies: Array) -> void:
	for child in lobby_container.get_children():
		child.queue_free()
		
	for lobby in lobbies:
		lobby_container.add_child(create_lobby_button(lobby))


func create_lobby_button(lobby: Dictionary) -> Button:
	var button := Button.new()

	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = ICONS
	atlas_texture.region.position.x = ICON_WIDTH * (lobby.player_count - 1)
	atlas_texture.region.position.y = 0 if !lobby.has_password else ICON_HEIGHT
	atlas_texture.region.size.x = ICON_WIDTH
	atlas_texture.region.size.y = ICON_HEIGHT
	button.icon = atlas_texture
	
	button.text = lobby.name
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.align = Button.ALIGN_LEFT
# warning-ignore:return_value_discarded
	button.connect("pressed", self, "join_lobby", [lobby])
	return button


func join_lobby(lobby: Dictionary) -> void:
	SignalingClient.join_lobby(lobby.id)
	emit_signal("transition", "Lobby")


func _on_Back_pressed() -> void:
	emit_signal("transition_back")
