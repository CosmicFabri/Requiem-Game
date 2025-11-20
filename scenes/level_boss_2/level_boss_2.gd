extends Node3D

@onready var score_label = %ScoreLabel
@onready var spawn_point = %SpawnPoint
@onready var brutus_spawn_point = %BrutusSpawnPoint
@onready var start_timer = %StartTimer
@onready var player_timer = %PlayerTimer

const brutus = preload("res://mobs/boss_2/brutus.tscn")
var brutus_instance: CharacterBody3D

var local_score = 0

func _ready():
	Player.global_position = spawn_point.global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	score_label.text = "Score: " + str(GameManager.score)
	spawn_brutus()
	start_level_transition()
	start_timer.start()
	player_timer.start()
	
	for spike in get_tree().get_nodes_in_group("spikes"):
		spike.body_entered.connect(_on_spike)

func increase_score():
	GameManager.score += 20
	local_score += 20
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
	
func _on_brutus_died() -> void:
	do_poof(brutus_instance.global_position)
	increase_score()
	end_level_transition()

func spawn_brutus():
	brutus_instance = brutus.instantiate()
	add_child(brutus_instance)
	brutus_instance.global_position = brutus_spawn_point.global_position
	brutus_instance.deactivate()
	brutus_instance.died.connect(_on_brutus_died)
	
	# Player shouldn't be able to shoot when starting the level
	Player.deactivate()
	Player.visible = true
	
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

func _on_start_timer_timeout():
	if brutus_instance:
		brutus_instance.activate()

func _on_player_timer_timeout():
	Player.activate()
	
func _on_spike(body):
	if body != Player:
		return
	
	Player.remove_heart()
	Player.global_position = spawn_point.global_position
