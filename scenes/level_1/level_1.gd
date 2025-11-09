extends Node3D

var score = 0
@onready var score_label = %ScoreLabel

var mobs_spawned = 0

func increase_score():
	score += 1
	score_label.text = "Score: " + str(score)
	
func do_poof(mob_global_position):
	const SMOKE_PUFF = preload("uid://cjk3frr43yesb")
	var poof = SMOKE_PUFF.instantiate()
	add_child(poof)
	poof.global_position = mob_global_position

func _on_mob_spawner_3d_mob_spawned(mob):
	mob.score.connect(increase_score)
	mob.died.connect(func on_mob_died():
		do_poof(mob.global_position)
	)
	do_poof(mob.global_position)
	mobs_spawned += 1
	print(mobs_spawned)
	
	if mobs_spawned > 2:
		LevelManager.next_level()

func _on_kill_plane_body_entered(body):
	get_tree().reload_current_scene.call_deferred()
