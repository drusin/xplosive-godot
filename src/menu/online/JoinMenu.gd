extends AbstractMenu

const ICON_PATH_TEMPLATE = "res://assets/lobby-icons/%s_%d.png"
var ICONS = load("res://assets/lobby-icons/icons.png")

onready var back_button = $GridContainer/Back
onready var lobby_container = $GridContainer/Control/ScrollContainer/LobbyContainer


func _ready():
	fullscreen = true
# warning-ignore:return_value_discarded
	SignalingClient.connect("lobby_list_recieved", self, "update_lobbies")
	
	
func focus_default():
	back_button.grab_focus()


func update_lobbies(lobbies):
	for child in lobby_container.get_children():
		child.queue_free()
		
	for lobby in lobbies:
		lobby_container.add_child(create_lobby_button(lobby))


func create_lobby_button(lobby):
	var button = Button.new()

	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = ICONS
	atlas_texture.region.position.x = 5 * (lobby.player_count - 1)
	atlas_texture.region.position.y = 0 if !lobby.has_password else 7
	atlas_texture.region.size.x = 5
	atlas_texture.region.size.y = 7
	button.icon = atlas_texture
	
	button.text = lobby.name
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.align = Button.ALIGN_LEFT
	button.connect("pressed", self, "join_lobby", [lobby])
	return button


func join_lobby(lobby):
	SignalingClient.join_lobby(lobby.id)
	emit_signal("transition", "Lobby")


func _on_Back_pressed():
	emit_signal("transition_back")
