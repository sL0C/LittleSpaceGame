extends Node

onready var tree = get_tree()
onready var root = tree.get_root()
onready var players = tree.get_nodes_in_group("Player")

# 1. level paths.
const resoure_path: String  = "res://resource"
const assets_path: String  = "res://assets"
const scenes_path: String  = "res://scenes"
const src_path: String  = "res://src"
# 2. level paths.
const player_scene_path: String = scenes_path + "/Player.tscn"
const basic_level_path: String = scenes_path + "/level/basic_level.tscn"


func _ready():
	print(players)

func get_filelist(scan_dir: String, suffix: String) -> Array:
	"""
	Traverse the target directory and all sub folder and return a list, 
	with paths of every file with the given suffix in the target folder. 
	"""
	var my_files : Array = []
	var dir := Directory.new()
	if dir.open(scan_dir) != OK:
		printerr("Warning: could not open directory: ", scan_dir)
		return []

	if dir.list_dir_begin(true, true) != OK:
		printerr("Warning: could not list contents of: ", scan_dir)
		return []

	var file_name := dir.get_next()
	while file_name:
		
		if dir.current_is_dir():
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name, suffix)
		elif file_name.ends_with(suffix):
			my_files.append(dir.get_current_dir() + "/" + file_name)
			
		file_name = dir.get_next()

	return my_files

func get_bundled_node_name(bundled: Dictionary) -> String:
	return bundled["names"][0]
	
	
