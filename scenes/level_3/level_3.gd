extends Node3D

@onready var score_label = %ScoreLabel
@onready var spawn_point = %SpawnPoint

var local_score = 0

func _ready():
	Player.global_position = spawn_point.global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	score_label.text = "Score: " + str(GameManager.score)

	for spawner in get_tree().get_nodes_in_group("mob_spawners"):
		spawner.mob_spawned.connect(_on_mob_spawned)

	start_level_transition()

func increase_score():
	GameManager.score += 1
	local_score += 1
	score_label.text = "Score: " + str(GameManager.score)

func do_poof(mob_global_position):
	const SMOKE_PUFF = preload("uid://cjk3frr43yesb")
	var poof = SMOKE_PUFF.instantiate()
	add_child(poof)
	poof.global_position = mob_global_position

# Drop de powerup: raycast hacia el suelo y colocar pickup en plataformas
func maybe_drop_powerup(origin: Vector3):
	if randf() > 0.25:		# probabilidad de drop powerup
		return
	var space := get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.create(origin + Vector3.UP * 2.0, origin + Vector3.DOWN * 100.0)
	var hit := space.intersect_ray(params)
	if hit.has("position") == false:
		return
	var pos: Vector3 = hit["position"] + Vector3.UP * 0.2
	const POWERUP_SCENE = preload("res://scenes/powerups/powerup.tscn")
	var p := POWERUP_SCENE.instantiate()
	add_child(p)
	p.global_position = pos
	p.powerup_type = randi() % 4

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
		maybe_drop_powerup(mob.global_position)

		if local_score >= 10:
			end_level_transition()
	)

	do_poof(mob.global_position)

func start_level_transition():
	var fade_anim: AnimationPlayer = %FadeIn

	fade_anim.animation_finished.connect(func(anim_name):
		if anim_name == "fade_in":
			pass
	)

	fade_anim.play("fade_in")

func end_level_transition():
	var fade_anim: AnimationPlayer = %FadeOut
	if not fade_anim.animation_finished.is_connected(_on_fade_out_finished):
		fade_anim.animation_finished.connect(_on_fade_out_finished)
	fade_anim.play("fade_out")

func _on_fade_out_finished(anim_name):
	if anim_name == "fade_out":
		GameManager.next_level()
