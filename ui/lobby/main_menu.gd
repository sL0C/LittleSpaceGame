extends PanelContainer

onready var ip_text_field = find_node("IPTextField")
func _ready():
	pass # Replace with function body.

func _on_HostGameButton_pressed():
	NetworkManager.host_game()


func _on_JoinGameButton_pressed():
	var ip = ip_text_field.text
	NetworkManager.join_game(ip)

func _on_SettingsButton_pressed():
	print("Not Implemented")
	pass # Replace with function body.


func _on_ExitButton_pressed():
	get_tree().quit()
