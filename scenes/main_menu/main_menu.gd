extends Control

func _ready():
	Player.deactivate()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.score = 0
	GameManager.lives = 3
	
func _on_start_pressed() -> void:
	Player.activate()
	get_tree().change_scene_to_file("res://scenes/level_1/level_1.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/instrucciones.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
