extends Node

signal lobby_list_recieved(lobbies)
signal lobby_update_recieved(lobby)
signal lobby_deleted(lobby_id)

const PEER_CONFIG = { "iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ] }

const MESSAGES = {
	# identification
	ID = "ID",
	PEER = "PEER",
	REMOVE_PEER = "REMOVE_PEER",
	# webrtc handshake
	OFFER = "OFFER",
	ANSWER = "ANSWER",
	CANDIDATE = "CANDIDATE",
	# lobby related
	CREATE_LOBBY = "CREATE_LOBBY",
	SEAL_LOBBY = "SEAL_LOBBY",
	JOIN_LOBBY = "JOIN_LOBBY",
	LEAVE_LOBBY = "LEAVE_LOBBY",
	DELETE_LOBBY = "DELETE_LOBBY",
	LOBBY_UPDATE = "LOBBY_UPDATE",
	LOBBY_LIST = "LOBBY_LIST",
	HOST_ID = "HOST_ID",
	ALIAS = "ALIAS",
	# old, still needed?
	START_SERVER = "START_SERVER",
	JOIN_SERVER = "JOIN_SERVER",
	SERVER_ID = "SERVER_ID",
}

var client = WebSocketClient.new()
var rtc_multiplayer = WebRTCMultiplayer.new()
var game


func _ready():
	client.connect("connection_established", self, "_on_connection_established")
	client.connect("data_received", self, "_on_data_received")


func _process(_delta):
	rtc_multiplayer.poll()
	var status = client.get_connection_status()
	if status == WebSocketClient.CONNECTION_CONNECTING or status == WebSocketClient.CONNECTION_CONNECTED:
		client.poll()


func init(game_name):
	game = game_name


func connect_to(url):
	client.connect_to_url(url)


func disconnect_from_host():
	client.disconnect_from_host()


func send_alias(alias):
	_send_message(MESSAGES.ALIAS, { alias = alias })


func create_lobby(name, password, max_players):
	_send_message(MESSAGES.CREATE_LOBBY, {
		name = name,
		password = password,
		maxPlayers = max_players,
		game = game
	})


func join_lobby(lobby_id):
	_send_message(MESSAGES.JOIN_LOBBY, { id = lobby_id })


func leave_lobby():
	_send_message(MESSAGES.LEAVE_LOBBY)


func seal_lobby():
	_send_message(MESSAGES.SEAL_LOBBY)


func delete_lobby():
	_send_message(MESSAGES.DELETE_LOBBY)


func disconnect_from_peer(peer_id):
	rtc_multiplayer.remove_peer(peer_id)


func disconnect_all_peers():
	for id in rtc_multiplayer.get_peers().keys():
		disconnect_from_peer(id)


func send_offer(id, sdp):
	_send_message(MESSAGES.OFFER, { id = id, sdp = sdp })


func send_answer(id, sdp):
	_send_message(MESSAGES.ANSWER, { id = id, sdp = sdp })


func send_candidate(id, mid_name, index_name, sdp_name):
	_send_message(MESSAGES.CANDIDATE, {
		id = id,
		midName = mid_name, 
		indexName = index_name, 
		sdpName = sdp_name
	})


func _on_connected(id):
	rtc_multiplayer.initialize(id, true)
	get_tree().set_network_peer(rtc_multiplayer)
	print('My ID: ' + str(id))


func _on_peer_connected(id):
	if id == rtc_multiplayer.get_unique_id():
		return
	var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
# warning-ignore:return_value_discarded
	peer.initialize(PEER_CONFIG)
# warning-ignore:return_value_discarded
	peer.connect("session_description_created", self, "_on_session_description_created", [id])
# warning-ignore:return_value_discarded
	peer.connect("ice_candidate_created", self, "_on_ice_candidate_created", [id])
	rtc_multiplayer.add_peer(peer, id)
	print("Peer added: ", id)


func _on_peer_disconnected(id):
	disconnect_from_peer(id)
	print("Peer removed: ", id)


func _on_session_description_created(type, sdp, id):
	rtc_multiplayer.get_peer(id).connection.set_local_description(type, sdp)
	match type:
		'offer': SignalingClient.send_offer(id, sdp)
		'answer': SignalingClient.send_answer(id, sdp)


func _on_host_id_recieved(id):
	if id == rtc_multiplayer.get_unique_id():
		return
	rtc_multiplayer.get_peer(id).connection.create_offer()


func _on_offer_recieved(id, offer):
	rtc_multiplayer.get_peer(id).connection.set_remote_description("offer", offer)
	
	
func _on_answer_recieved(id, answer):
	rtc_multiplayer.get_peer(id).connection.set_remote_description("answer", answer)
	
	
func _on_candiate_recieved(id, mid_name, index_name, sdp_name):
	rtc_multiplayer.get_peer(id).connection.add_ice_candidate(mid_name, index_name, sdp_name)
	

func _on_ice_candidate_created(mid_name, index_name, sdp_name, id):
	send_candidate(id, mid_name, index_name, sdp_name)


func _send_message(header, payload: = {}):
	client.get_peer(1).put_packet(_create_msg(header, payload).to_utf8())


static func _create_msg(type, payload: = {}):
	return JSON.print({
		"type": type,
		"payload": payload
	})


func _on_connection_established(_protocol):
	print(client.get_connected_host())
	client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)


func _on_data_received():
	_parse_message(JSON.parse(
			client.get_peer(1).get_packet().get_string_from_utf8()).result)


func _parse_message(message):
	print(message)
	match message.type:
		MESSAGES.ID:
			_on_connected(message.payload.id)
		MESSAGES.PEER:
			_on_peer_connected(message.payload.id)
		MESSAGES.REMOVE_PEER:
			_on_peer_disconnected(message.payload.id)
		MESSAGES.HOST_ID:
			_on_host_id_recieved(message.payload.id)
		MESSAGES.OFFER:
			_on_offer_recieved(message.payload.id, message.payload.sdp)
		MESSAGES.ANSWER:
			_on_answer_recieved(message.payload.id, message.payload.sdp)
		MESSAGES.CANDIDATE:
			_on_candiate_recieved(message.payload.id, message.payload.midName,
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
				players = players
			})
		MESSAGES.DELETE_LOBBY:
			emit_signal("lobby_deleted", message.payload.id)
		
