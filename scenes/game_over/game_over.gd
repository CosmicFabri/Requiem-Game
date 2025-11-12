extends Control

@onready var high_score_label = %HighScoreLabel
@onready var current_score_label = %CurrentScoreLabel

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	high_score_label.text = "High score: " + str(GameManager.high_score)
	current_score_label.text = "Current score: " + str(GameManager.score)

func _on_main_menu_button_pressed():
	GameManager.go_to_main_menu()
