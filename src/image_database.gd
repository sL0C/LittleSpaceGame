extends Node

const assets_path = Global.assets_path
var images = Array()

func _ready():
	"""
	Prepares all the image files in the assets folder for later use.
	"""
	var img_list = Global.get_filelist(assets_path, ".png")
	# Load every image file in the assets folder to fast call those later.
	for img in img_list:
		images.append(load(img))
	
func get_img(img_name):
	"""
	Returns an image by its name.
	"""
	for img in images:
		if img.name == img_name:
			return img
	return null
