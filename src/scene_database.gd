extends Node

const scenes_path = Global.scenes_path
var scenes = Array()
var cached = Dictionary()

func _ready():
	"""
	Prepares all the scene files in the scene folder for later use.
	"""
	var scn_list = Global.get_filelist(scenes_path, ".tscn")
	# Load every image file in the assets folder to fast call those later.
	for scn in scn_list:
		scenes.append(load(scn))

func get_scene(scene_name):
	"""
	Returns an scene by its name.
	"""
	# First look up the name in the cache.
	if scene_name in cached:
		print(scene_name, " was cached")
		return cached[scene_name]
	
	# Search the database for the scene
	for scn in scenes:
		if scn._bundled["names"][0] == scene_name:
			cached[scene_name] = scn.instance()
			return scn
	return null
