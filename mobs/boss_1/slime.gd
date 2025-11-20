extends RigidBody3D

signal died
signal score

var health = 20
var speed = 3.5
var jump_force = 8.0
var is_on_ground = false

@onready var slime_model: Node3D = %slime_model
@onready var timer: Timer = %Timer
@onready var kill_timer = %KillTimer
@onready var hurt_sound: AudioStreamPlayer3D = %HurtSound
@onready var ko_sound: AudioStreamPlayer3D = %KOSound
@onready var jump_timer: Timer = Timer.new()
@onready var attack_timer = %AttackTimer

func _ready():
	# Configurar timer para saltos
	add_child(jump_timer)
	jump_timer.wait_time = randf_range(1.0, 2.5)
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	jump_timer.start()
	
	# Activar detección de contacto con el suelo
	contact_monitor = true
	max_contacts_reported = 4
	
	# Bloquear rotación para que no gire
	lock_rotation = true
	kill_timer.start()

func _physics_process(_delta):
	# Setting the direction to the player's location
	var direction = global_position.direction_to(Player.global_position)
	direction.y = 0.0 # Not move up or down
	direction = direction.normalized()
	
	# Aplicar movimiento horizontal (sin afectar la Y)
	var current_velocity = linear_velocity
	current_velocity.x = direction.x * speed
	current_velocity.z = direction.z * speed
	linear_velocity = current_velocity
	
	# Rotar el modelo hacia la dirección
	slime_model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI

func _on_jump_timer_timeout():
	# Solo saltar si está en el suelo
	if is_on_ground:
		apply_central_impulse(Vector3.UP * jump_force)
		is_on_ground = false
	
	# Reiniciar timer con tiempo aleatorio
	jump_timer.wait_time = randf_range(1.0, 2.5)
	jump_timer.start()

func _integrate_forces(state):
	# Detectar si está en el suelo
	is_on_ground = false
	for i in state.get_contact_count():
		var normal = state.get_contact_local_normal(i)
		# Si la normal apunta hacia arriba, está en el suelo
		if normal.dot(Vector3.UP) > 0.7:
			is_on_ground = true
			break

func take_damage():
	if health == 0:
		return
	
	slime_model.hurt()
	hurt_sound.play()
	health -= 1
	
	if health == 0:
		set_physics_process(false)
		jump_timer.stop()
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

func _on_area_3d_body_entered(body):
	if body != Player: return
	
	if kill_timer.is_stopped() == false or attack_timer.is_stopped() == false:
		return
		
	Player.knockback_from(self)
	Player.remove_heart()
	
	if GameManager.lives < 1:
		GameManager.go_to_game_over()
		
	attack_timer.start()
