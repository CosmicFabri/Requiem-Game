extends RigidBody3D

signal died
signal score

var health = 3
var speed = randf_range(2.0, 4.0)

@onready var devil_model: Node3D = %devil_model
@onready var timer: Timer = %Timer

@onready var hurt_sound: AudioStreamPlayer3D = %HurtSound
@onready var ko_sound: AudioStreamPlayer3D = %KOSound

func _physics_process(_delta):
	# Setting the direction to the player's location
	var direction = global_position.direction_to(Player.global_position)
	direction.y = 0.0 # Not move up or down
	linear_velocity = direction * speed
	devil_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI

func take_damage():
	if health == 0:
		return
	
	devil_model.hurt()
	hurt_sound.play()
	health -= 1
	
	if health == 0:
		set_physics_process(false)
		gravity_scale = 1.0
		var direction = -1.0 * global_position.direction_to(Player.global_position)
		var random_upward_force = Vector3.UP * randf_range(1.0, 5.0)
		apply_central_impulse(direction * 10.0 + random_upward_force)
		timer.start()
		score.emit()
		ko_sound.play()

func _on_timer_timeout():
	queue_free()
	died.emit()
