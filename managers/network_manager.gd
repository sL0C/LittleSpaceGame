extends Node

const PORT = 13337

const MAXIMUM_PLAYERS = 2
var player_info = {}
var info

var other_player_id

var world_scene = "res://scenes/World/NotArena/NotArena.tscn"
var player_scene = "res://scenes/Player.tscn"
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
#	var world = load(world_scene).instance()
#	get_node('/root').add_child(world)
	var selfPeerID = get_tree().get_network_unique_id()
	get_node('/root').set_network_master(selfPeerID)
	get_tree().set_pause(true)
	rpc_id(1, "register_player" , selfPeerID)
	pre_configure_game()

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
	#if get_tree().is_network_server():
		#rpc('pre_configure_game')
	rpc_id(1, "register_player" , id)
	pre_configure_game()

var all_players = []
var players_done = []

master func register_player(peer_id):
	all_players.append(peer_id)
	print("registered player ", peer_id)

master func get_all_players():
	return all_players

remotesync func pre_configure_game():
	
	print("preconfigged")
	var selfPeerID = get_tree().get_network_unique_id()
	var world = load(world_scene).instance()
	
	get_node('/root').add_child(world)
	
	var spawn_points = get_tree().get_nodes_in_group("SpawnPoint")
	print(all_players.size())
	print(spawn_points.size())
	#all_players = rpc_id(1, "get_all_players")
#	var player = load(player_scene).instance()
#	player.global_position = spawn_points[all_players.find(selfPeerID)].global_position
#	get_node("/root/NotArena").add_child(player)
	#TODO: Add player info to player (for deletion)
	#player.get_node("Camera2D").current = true
	print("spawned_player")
	#var players_to_add = all_players.size() - players_done.size()
	for player_i in range(all_players.size()):
		if spawn_points.size() > player_i:
			var player = load(player_scene).instance()
			player.global_position = spawn_points[player_i].global_position
			get_node("/root/NotArena").add_child(player)
			player.get_node("Camera2D").current = true
			print("spawned_player")
			#spawn_player(all_players[player_i], spawn_points[player_i])
#		else:
#			spawn_player_randomly(all_players)
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
