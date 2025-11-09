extends Control


func _on_button_pressed() -> void:
	print("instrucciones pressed")# Replace with function body.
	get_tree().change_scene_to_file("res://main_menu.tscn")
