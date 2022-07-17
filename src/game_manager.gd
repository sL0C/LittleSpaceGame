extends Node

var player

signal player_initialised


func _process(_delta):
	if not player:
		initialise_player()
		_init_connections()
		return

func initialise_player():
	player = get_tree().get_root().get_node("/root/World/Player")
	if not player:
		return

	# Send a signal, when the player is initialised.
	emit_signal("player_initialised", player)

func _init_connections():
	pass
	# Connect all ingredients in the tree to the player which are already there.
#	var ingredients = get_tree().get_nodes_in_group("ingredient")
	
# Save the inventory data.
func _on_player_inventory_changed(inventory):
	pass
#	var result = ResourceSaver.save(inventory_data_path, inventory)
