extends Node

var rtc_multiplayer = WebRTCMultiplayer.new()


func _ready():
# warning-ignore:return_value_discarded
	SignalingClient.connect("connected", self, "_on_connected")
# warning-ignore:return_value_discarded
	SignalingClient.connect("peer_connected", self, "_on_peer_connected")
# warning-ignore:return_value_discarded
	SignalingClient.connect("server_id_recieved", self, "_on_server_id_recieved")
# warning-ignore:return_value_discarded
	SignalingClient.connect("offer_recieved", self, "_on_offer_recieved")
# warning-ignore:return_value_discarded
	SignalingClient.connect("answer_recieved", self, "_on_answer_recieved")
# warning-ignore:return_value_discarded
	SignalingClient.connect("candiate_recieved", self, "_on_candiate_recieved")


func _process(_delta):
	rtc_multiplayer.poll()


func _on_connected(id):
	rtc_multiplayer.initialize(id, true)
	get_tree().set_network_peer(rtc_multiplayer)
	print('My ID: ' + str(id))


func _on_peer_connected(id):
	if id == rtc_multiplayer.get_unique_id():
		return
	var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
# warning-ignore:return_value_discarded
	peer.initialize(SignalingClient.PEER_CONFIG)
# warning-ignore:return_value_discarded
	peer.connect("session_description_created", self, "_on_session_description_created", [id])
# warning-ignore:return_value_discarded
	peer.connect("ice_candidate_created", self, "_on_ice_candidate_created", [id])
	rtc_multiplayer.add_peer(peer, id)
	print('Peer added: ' + str(id))


func _on_session_description_created(type, sdp, id):
	rtc_multiplayer.get_peer(id).connection.set_local_description(type, sdp)
	match type:
		'offer': SignalingClient.send_offer(id, sdp)
		'answer': SignalingClient.send_answer(id, sdp)


func _on_server_id_recieved(id):
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
	SignalingClient.send_candidate(id, mid_name, index_name, sdp_name)
