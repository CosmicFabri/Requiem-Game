extends Control

func _ready():
	$VBoxContainer/PlayButton.connect("pressed", _on_play_pressed)
	$VBoxContainer/InstructionsButton.connect("pressed", _on_instructions_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/level_1/level_1.tscn")

func _on_instructions_pressed():
	$InstructionsPopup.popup_centered()  # Opens the modal window
