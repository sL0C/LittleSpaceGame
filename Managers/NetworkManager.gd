extends Node


const PORT = 13337

const MAXIMUM_PLAYERS = 2
var player_info = {}
var info
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func host_game():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAXIMUM_PLAYERS)
	get_tree().set_network_peer(peer)
	print("hosting game")
	connected_to_server()

func join_game(ip):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, PORT)
	get_tree().set_network_peer(peer)
	print("joining game on ", ip, ":" , PORT)
	info = { get_tree().get_network_unique_id(): "Tester"}

func _player_connected(id):
	# Called on both clients and server when a peer connects.
	rpc_id(id, "register_player")

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	print("connected ok")
	connected_to_server()
	

func _server_disconnected():
	print("Server kicked us; show error and abort.")

func _connected_fail():
	print("Could not even connect to server; abort.")

func connected_to_server():
	print("connected to server")
	rpc("register_player", info)
	#rpc("register_player", get_tree().get_network_unique_id(), info)
	#register_player(get_tree().get_network_unique_id())
	
	

remotesync func register_player(info):
	print("registering player")
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info
	# Call function to update lobby UI here
	pre_configure_game()
	print("configuring game")

var world_scene = "res://Scenes/Test/NotArena.tscn"
var player_scene = "res://Scenes/Test/NotPlayer/NotPlayer.tscn"

remotesync func pre_configure_game():
	get_tree().set_pause(true)
	var selfPeerID = get_tree().get_network_unique_id()
	
	# Load world
	#var world = load(world_scene).instance()
	#get_node("/root").add_child(world)
	#Delete MainMenu
	get_tree().change_scene(world_scene)
	yield(get_tree().create_timer(0.3), "timeout")
	var world_node = get_tree().get_nodes_in_group("World")[0]
	# Load my player
	var my_player = load(player_scene).instance()
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID) # Will be explained later
	
	world_node.get_node("Players").add_child(my_player)
	
	# Load Enemies
	for p in player_info:
		var player = load(player_scene).instance()
		player.set_name(str(p))
		player.set_network_master(p) # Will be explained later
		world_node.get_node("Players").add_child(player)
	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	rpc_id(1, "done_preconfiguring")


var players_done = []
remotesync func done_preconfiguring():
	var who = get_tree().get_rpc_sender_id()
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(who in player_info) # Exists
	assert(not who in players_done) # Was not added yet

	players_done.append(who)

	if players_done.size() == player_info.size() && player_info.size() >= 1:
		rpc("post_configure_game")

remotesync func post_configure_game():
	# Only the server is allowed to tell a client to unpause
	if 1 == get_tree().get_rpc_sender_id():
		get_tree().set_pause(false)
		# Game starts now!
