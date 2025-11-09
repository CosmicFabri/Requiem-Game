extends Node3D

@onready var score_label = %ScoreLabel

var local_score = 0

func _ready():
	score_label.text = "Score: " + str(GameManager.score)

func increase_score():
	GameManager.score += 1
	local_score += 1
	score_label.text = "Score: " + str(GameManager.score)
	print(GameManager.score)
	
func do_poof(mob_global_position):
	const SMOKE_PUFF = preload("uid://cjk3frr43yesb")
	var poof = SMOKE_PUFF.instantiate()
	add_child(poof)
	poof.global_position = mob_global_position

func _on_mob_spawner_3d_mob_spawned(mob):
	mob.score.connect(increase_score)
	mob.died.connect(func on_mob_died():
		do_poof(mob.global_position)
		
		if local_score >= 3:
			GameManager.next_level()
	)
	do_poof(mob.global_position)

func _on_kill_plane_body_entered(body):
	get_tree().reload_current_scene.call_deferred()
