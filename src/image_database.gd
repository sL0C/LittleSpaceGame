extends Node

const assets_path = "res://assets"
var images = Array()

func _ready():
	"""
	Prepares all the image files in the assets folder for later use.
	"""
	var img_list = get_filelist(assets_path)
	
	# Load every image file in the assets folder to fast call those later.
	for img in img_list:
		images.append(load(img))
	
func get_filelist(scan_dir : String) -> Array:
	"""
	Traverse the target directory and all sub folder and return a list, 
	with paths of every image file in the target folder. 
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
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name)
		elif file_name.ends_with(".png"):
			my_files.append(dir.get_current_dir() + "/" + file_name)
			
		file_name = dir.get_next()
	return my_files
	
func get_img(img_name):
	"""
	Returns an image by its name.
	"""
	for img in images:
		if img.name == img_name:
			return img
	return null
