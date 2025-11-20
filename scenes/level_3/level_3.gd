extends Node3D

@onready var score_label = %ScoreLabel
@onready var spawn_point = %SpawnPoint

var local_score = 0

func _ready():
	GameManager.current_level_index = 2
	Player.global_position = spawn_point.global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	score_label.text = "Score: " + str(GameManager.score)
	
	for spawner in get_tree().get_nodes_in_group("mob_spawners"):
		spawner.mob_spawned.connect(_on_mob_spawned)
		
	var fade_anim = %FadeIn
	fade_anim.play("fade_in")

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
		
func _on_mob_spawned(mob):
	mob.score.connect(increase_score)
	mob.died.connect(func on_mob_died():
		do_poof(mob.global_position)

		if local_score >= 15:
			end_level_transition()
	)
	
	do_poof(mob.global_position)
	
func end_level_transition():
	var fade_anim: AnimationPlayer = %FadeOut
	# When fade finishes, go to the next level
	fade_anim.animation_finished.connect(func(anim_name):
		if anim_name == "fade_out":
			GameManager.next_level()
	)

	# Start fade
	fade_anim.play("fade_out")
