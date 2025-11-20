extends CharacterBody3D

signal died
signal score

@export var health := 25
@export var speed := 3.3
@export var gravity := 9.8

@onready var brutus_model: Node3D = %Brutus_model
@onready var timer: Timer = %Timer
@onready var hurt_sound: AudioStreamPlayer3D = %HurtSound
@onready var ko_sound: AudioStreamPlayer3D = %KOSound
@onready var attack_timer = %AttackTimer

var is_dead := false

func activate():
	set_physics_process(true)
	set_collision_layer_value(1, true)

func deactivate():
	set_physics_process(false)
	set_collision_layer_value(1, false)
	velocity = Vector3.ZERO

func _physics_process(delta):
	# If dead → only falling physics works
	if is_dead:
		velocity.y -= gravity * delta
		move_and_slide()
		return

	_movement_logic(delta)

func _movement_logic(delta):
	var direction = (Player.global_position - global_position)
	direction.y = 0.0
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

	# Rotate model toward movement direction
	var target_angle = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI
	brutus_model.rotation.y = lerp_angle(
		brutus_model.rotation.y,
		target_angle,
		delta * 8.0
	)

func take_damage():
	if health <= 0:
		return

	brutus_model.hurt()
	hurt_sound.play()

	health -= 1

	if health == 0:
		_die()

func _die():
	if is_dead:
		return
	is_dead = true

	ko_sound.play()
	score.emit()

	# Stop normal movement and AI
	set_physics_process(false)

	# Apply knockback manually (CharacterBody version)
	var direction = (global_position - Player.global_position).normalized()
	var upward_force = Vector3.UP * randf_range(3.0, 6.0)

	velocity = direction * 10.0 + upward_force

	# Allow gravity to act during fall
	set_physics_process(true)

	# Auto-delete after falling
	timer.start()

func _on_timer_timeout():
	queue_free()
	died.emit()

func _on_area_3d_body_entered(body):
	if body != Player: 
		return

	if health <= 0:
		return

	if attack_timer.is_stopped():
		Player.knockback_from(self)
		Player.remove_heart()

		if GameManager.lives < 1:
			GameManager.go_to_game_over()

	attack_timer.start()
