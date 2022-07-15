extends Node

const PORT = 13337

const MAXIMUM_PLAYERS = 3
var player_info = {}
var info

var other_player_id
var players_done = []
var world_scene = "res://scenes/World/NotArena/NotArena.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	#get_tree().connect("connected_to_server", self, "_connected_ok")
	#get_tree().connect("connection_failed", self, "_connected_fail")
	#get_tree().connect("server_disconnected", self, "_server_disconnected")
	pause_mode = PAUSE_MODE_PROCESS

func _player_disconnected(id):
	print(id, "left the game")
	pass

func host_game():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAXIMUM_PLAYERS)
	get_tree().set_network_peer(peer)
	print("hosting game")
	var world = load(world_scene).instance()
	get_node('/root').add_child(world)
	var selfPeerID = get_tree().get_network_unique_id()
	get_node('/root').set_network_master(selfPeerID)
	get_tree().set_pause(true)

func join_game(ip):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, PORT)
	get_tree().set_network_peer(peer)
	print("joining game on ", ip, ":" , PORT)
	info = { get_tree().get_network_unique_id(): "Tester"}
	

func _player_connected(id):
	print(id, "connected")
	get_tree().refuse_new_network_connections = true
	other_player_id = id
	if get_tree().is_network_server():
		rpc('pre_configure_game')


remotesync func pre_configure_game():
	
	print("preconfigged")
	var selfPeerID = get_tree().get_network_unique_id()

	var world = load(world_scene).instance()

	get_node('/root').add_child(world)
	
	rpc("done_preconfiguring", selfPeerID)

master func done_preconfiguring(who):
	assert(not who in players_done)

	players_done.append(who)

	if players_done.size() == 2:
		rpc("post_configure_game")
	print("done with ", players_done.size(), " players")


remotesync func post_configure_game():
	get_tree().set_pause(false)
	#emit_signal('exit_lobby')
