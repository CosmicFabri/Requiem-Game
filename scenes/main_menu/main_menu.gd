extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	
func _on_start_pressed() -> void:
	print("start pressed")
	get_tree().change_scene_to_file("res://scenes/level_1/level_1.tscn")


func _on_settings_pressed() -> void:
	print("settings pressed") # Replace with function body.
	get_tree().change_scene_to_file("res://scenes/main_menu/instrucciones.tscn")

func _on_exit_pressed() -> void:
	print("exit pressed")# Replace with function body.
	get_tree().quit()
