extends Node3D

@onready var score_label = %ScoreLabel
@onready var spawn_point = %SpawnPoint
@onready var new_spawn_point = %NewSpawnPoint
@onready var slime_spawn_point = %SlimeSpawnPoint
@onready var csg_box_3d_5 = %CSGBox3D5
@onready var csg_box_3d_6 = %CSGBox3D6

const slime = preload("res://mobs/boss_1/slime.tscn")
var slime_instance: RigidBody3D

var local_score = 0

func _ready():
	Player.global_position = spawn_point.global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	score_label.text = "Score: " + str(GameManager.score)
	start_level_transition()

func increase_score():
	GameManager.score += 10
	local_score += 10
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
	do_poof(slime_instance.global_position)
	increase_score()
	end_level_transition()

func _on_slime_trigger_body_entered(body):
	if (!slime_spawn_point): return
	
	if body != Player:
		return
		
	slime_spawn_point.queue_free()
	spawn_point = new_spawn_point
	csg_box_3d_5.queue_free()
	csg_box_3d_6.queue_free()

	slime_instance = slime.instantiate()
	add_child(slime_instance)
	slime_instance.global_position = slime_spawn_point.global_position
	#slime_instance.global_rotation = slime_spawn_point.global_rotation
	slime_instance.died.connect(_on_slime_died)
	
func start_level_transition():
	var fade_anim: AnimationPlayer = %FadeIn
	
	fade_anim.animation_finished.connect(func(anim_name):
		if anim_name == "fade_in":
			pass
	)
	
	fade_anim.play("fade_in")
	
func end_level_transition():
	var fade_anim: AnimationPlayer = %FadeOut
	# When fade finishes, go to the next level
	fade_anim.animation_finished.connect(_on_fade_out_finished)
	
	# Start fade
	fade_anim.play("fade_out")

func _on_fade_out_finished(anim_name):
	if anim_name == "fade_out":
		GameManager.next_level()
