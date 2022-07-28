extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 4545

var network = NetworkedMultiplayerENet.new()
var selected_ip
var selected_port

var local_player_id = 0
sync var players = {}
sync var player_data = {}

func _ready():
	get_tree().
