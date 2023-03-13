class_name SignalingClient
extends Node

signal connection_established()
signal connection_closed()

signal lobby_list_recieved(lobbies)
signal lobby_update_recieved(lobby)
signal lobby_deleted(lobby_id)

const PEER_CONFIG := { "iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ] }

const MESSAGES := {
	# identification
	ID = "ID",
	PEER = "PEER",
	REMOVE_PEER = "REMOVE_PEER",
	SET_GAME = "SET_GAME",
	SET_ALIAS = "SET_ALIAS",
	SET_PLAYER_DATA = "SET_PLAYER_DATA",
	# webrtc handshake
	OFFER = "OFFER",
	ANSWER = "ANSWER",
	CANDIDATE = "CANDIDATE",
	# lobby related
	CREATE_LOBBY = "CREATE_LOBBY",
	EDIT_LOBBY = "EDIT_LOBBY",
	SEAL_LOBBY = "SEAL_LOBBY",
	JOIN_LOBBY = "JOIN_LOBBY",
	LEAVE_LOBBY = "LEAVE_LOBBY",
	DELETE_LOBBY = "DELETE_LOBBY",
	LOBBY_UPDATE = "LOBBY_UPDATE",
	LOBBY_LIST = "LOBBY_LIST",
	# old, still needed?
	START_SERVER = "START_SERVER",
	JOIN_SERVER = "JOIN_SERVER",
	SERVER_ID = "SERVER_ID",
}

var game: String

var _client := WebSocketPeer.new()
var _rtc_multiplayer := WebRTCMultiplayerPeer.new()


func _ready() -> void:
# warning-ignore:return_value_discarded
	#_client.connect("connection_closed", Callable(self,"_on_connection_closed"))
# warning-ignore:return_value_discarded
	#_client.connect("data_received", Callable(self,"_on_data_received"))
	pass


func _process(_delta) -> void:
	_rtc_multiplayer.poll()
	var status = _client.get_ready_state()
	if status == WebSocketPeer.STATE_CONNECTING or status == WebSocketPeer.STATE_OPEN:
		_client.poll()


func init(game_name: String) -> void:
	game = game_name


func connect_to(url: String, alias: String) -> void:
# warning-ignore:return_value_discarded
	_client.connect("connection_established",Callable(self,"_on_connection_established").bind(alias))
# warning-ignore:return_value_discarded
	_client.connect_to_url(url)


func disconnect_from_host() -> void:
	_client.disconnect_from_host()


func send_alias(alias: String) -> void:
	_send_message(MESSAGES.SET_ALIAS, { alias = alias })


func send_player_data(data: Dictionary) -> void:
	_send_message(MESSAGES.SET_PLAYER_DATA, { data = data })


func create_lobby(lobby_name: String, password: String, max_players: int, data := {}) -> void:
	_send_message(MESSAGES.CREATE_LOBBY, {
		name = lobby_name,
		password = password,
		maxPlayers = max_players,
		game = game,
		data = data
	})


func edit_lobby(id: int, lobby_name: String, password: String, max_players: int, data := {}) -> void:
	_send_message(MESSAGES.EDIT_LOBBY, {
		id = id,
		name = lobby_name,
		password = password,
		maxPlayers = max_players,
		data = data
	})

func join_lobby(lobby_id: int, password := "") -> void:
	_send_message(MESSAGES.JOIN_LOBBY, { id = lobby_id, password = password })


func leave_lobby() -> void:
	_send_message(MESSAGES.LEAVE_LOBBY)


func seal_lobby() -> void:
	_send_message(MESSAGES.SEAL_LOBBY)


func delete_lobby() -> void:
	_send_message(MESSAGES.DELETE_LOBBY)


func disconnect_from_peer(peer_id: int) -> void:
	_rtc_multiplayer.remove_peer(peer_id)


func disconnect_all_peers() -> void:
	for id in _rtc_multiplayer.get_peers().keys():
		disconnect_from_peer(id)


func _on_connection_established(_protocol, alias: String) -> void:
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	_send_game()
	send_alias(alias)
	emit_signal("connection_established")


func _send_game() -> void:
	_send_message(MESSAGES.SET_GAME, { "game": game })
	

func _on_connection_closed(_was_clean_close) -> void:
	_client.disconnect("connection_established",Callable(self,"_on_connection_established"))
	emit_signal("connection_closed")


func _on_data_received() -> void:
	_parse_message(JSON.parse_string(
			_client.get_peer(1).get_packet().get_string_from_utf8()).result)


func _parse_message(message: Dictionary) -> void:
	print(message.type)
	match message.type:
		MESSAGES.ID:
			_initialize_mp(message.payload.id)
		MESSAGES.PEER:
			_add_peer(message.payload.id)
		MESSAGES.REMOVE_PEER:
			_remove_peer(message.payload.id)
		MESSAGES.OFFER:
			_set_offer(message.payload.id, message.payload.sdp)
		MESSAGES.ANSWER:
			_set_answer(message.payload.id, message.payload.sdp)
		MESSAGES.CANDIDATE:
			_add_candidate(message.payload.id, message.payload.midName,
					message.payload.indexName, message.payload.sdpName)
		MESSAGES.LOBBY_LIST:
			var lobbies = []
			for lobby in message.payload:
				lobbies.append({
					id = lobby.id,
					name = lobby.name,
					has_password = lobby.hasPassword,
					player_count = lobby.playerCount
				})
			emit_signal("lobby_list_recieved", lobbies)
		MESSAGES.LOBBY_UPDATE:
			var players = []
			for player in message.payload.players:
				players.append({
					alias = player.alias,
					is_host = player.isHost,
					id = player.id
				})
			emit_signal("lobby_update_recieved", {
				id = message.payload.id,
				name = message.payload.name,
				has_password = message.payload.hasPassword,
				max_players = message.payload.maxPlayers,
				players = players
			})
		MESSAGES.DELETE_LOBBY:
			emit_signal("lobby_deleted", message.payload.id)


func _initialize_mp(id: int) -> void:
# warning-ignore:return_value_discarded
	_rtc_multiplayer.initialize(id, true)
	get_tree().set_multiplayer_peer(_rtc_multiplayer)
	print('My ID: ' + str(id))


func _add_peer(id: int) -> void:
	if id == _rtc_multiplayer.get_unique_id():
		return
	var peer := WebRTCPeerConnection.new()
# warning-ignore:return_value_discarded
	peer.initialize(PEER_CONFIG)
# warning-ignore:return_value_discarded
	peer.connect("session_description_created",Callable(self,"_on_session_description_created").bind(id))
# warning-ignore:return_value_discarded
	peer.connect("ice_candidate_created",Callable(self,"_on_ice_candidate_created").bind(id))
# warning-ignore:return_value_discarded
	_rtc_multiplayer.add_peer(peer, id)
	print("Peer added: ", id)
	if _rtc_multiplayer.get_unique_id() != MultiplayerPeer.TARGET_PEER_SERVER:
		_rtc_multiplayer.get_peer(id).connection.create_offer()


func _on_session_description_created(type, sdp, id) -> void:
	_rtc_multiplayer.get_peer(id).connection.set_local_description(type, sdp)
	match type:
		'offer': _send_offer(id, sdp)
		'answer': _send_answer(id, sdp)


func _send_offer(id, sdp) -> void:
	_send_message(MESSAGES.OFFER, { id = id, sdp = sdp })


func _send_answer(id, sdp) -> void:
	_send_message(MESSAGES.ANSWER, { id = id, sdp = sdp })


func _on_ice_candidate_created(mid_name, index_name, sdp_name, id) -> void:
	_send_message(MESSAGES.CANDIDATE, {
		id = id,
		midName = mid_name, 
		indexName = index_name, 
		sdpName = sdp_name
	})


func _remove_peer(id: int) -> void:
	disconnect_from_peer(id)
	print("Peer removed: ", id)


func _set_offer(id, offer) -> void:
	_rtc_multiplayer.get_peer(id).connection.set_remote_description("offer", offer)


func _set_answer(id, answer) -> void:
	_rtc_multiplayer.get_peer(id).connection.set_remote_description("answer", answer)


func _add_candidate(id, mid_name, index_name, sdp_name) -> void:
	_rtc_multiplayer.get_peer(id).connection.add_ice_candidate(mid_name, index_name, sdp_name)


func _send_message(header: String, payload: = {}) -> void:
# warning-ignore:return_value_discarded
	_client.get_peer(1).put_packet(SignalingClient._create_msg(header, payload).to_utf8_buffer())


static func _create_msg(type: String, payload: = {}) -> String:
	return JSON.stringify({
		"type": type,
		"payload": payload
	})
