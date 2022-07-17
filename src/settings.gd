extends Node

var screen_width = ProjectSettings.get_setting("display/window/size/width")
var screen_height = ProjectSettings.get_setting("display/window/size/height")

func _ready():
	OS.set_current_screen(0)
	print("Screen size: %sx%s" % [screen_width, screen_height])
	
