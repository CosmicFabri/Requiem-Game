extends Node3D

@onready var score_label = %ScoreLabel
@onready var spawn_point = %SpawnPoint

var local_score = 0

func _ready():
	GameManager.current_level_index = 3  # Ajusta según tu índice de nivel
	Player.global_position = spawn_point.global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	score_label.text = "Score: " + str(GameManager.score)

func increase_score():
	GameManager.score += 1
	local_score += 1
	score_label.text = "Score: " + str(GameManager.score)
	
func do_poof(mob_global_position):
	const SMOKE_PUFF = preload("uid://cjk3frr43yesb")
	var poof = SMOKE_PUFF.instantiate()
	add_child(poof)
	poof.global_position = mob_global_position
	
func _on_kill_plane_body_entered(body):
	if body == Player:
		Player.global_position = spawn_point.global_position
		Player.remove_heart()
			
		if GameManager.lives <= 0:
			GameManager.update_high_score()
			GameManager.go_to_game_over()


func _on_slime_died() -> void:
	do_poof($Slime.global_position)
