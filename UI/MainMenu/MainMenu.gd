extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_HostGameButton_pressed():
	NetworkManager.host_game()


func _on_JoinGameButton_pressed():
	var ip = $CenterContainer/VBoxContainer/HBoxContainer/IPTextField.text
	NetworkManager.join_game(ip)

func _on_SettingsButton_pressed():
	print("Not Implemented")
	pass # Replace with function body.


func _on_ExitButton_pressed():
	get_tree().quit()
