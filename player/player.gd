extends CharacterBody3D

# -----------------------------------------
# Variables persistentes
# -----------------------------------------
var spawn_position: Vector3
var hearts: Array = []

var is_knockback := false
var knockback_timer := 0.2

@onready var hearts_container = %HeartsContainer

# SFX Nodes
@onready var death_sfx: AudioStreamPlayer = $DeathSFX
@onready var hurt_sfx: AudioStreamPlayer = $HurtSFX
@onready var push_sfx: AudioStreamPlayer = $PushSFX   # <-- NUEVO

# -----------------------------------------
# Sonidos de muerte
# -----------------------------------------
var death_sounds := [
	preload("res://player/sounds/deathsound1.mp3"),
	preload("res://player/sounds/deathsound2.mp3"),
	preload("res://player/sounds/deathsound3.mp3"),
	preload("res://player/sounds/deathsound4.mp3"),
	preload("res://player/sounds/deathsound5.mp3"),
	preload("res://player/sounds/deathsound6.mp3"),
]

# Sonidos de daño (pueden ser idénticos)
var hurt_sounds := [
	preload("res://player/sounds/deathsound1.mp3"),
	preload("res://player/sounds/deathsound2.mp3"),
	preload("res://player/sounds/deathsound3.mp3"),
	preload("res://player/sounds/deathsound4.mp3"),
	preload("res://player/sounds/deathsound5.mp3"),
	preload("res://player/sounds/deathsound6.mp3"),
]

# Sonido al ser empujado
var push_stream := preload("res://player/sounds/push.wav")

# -----------------------------------------
# Ready
# -----------------------------------------
func _ready():
	randomize()

	if hearts_container == null:
		push_warning("HeartsContainer not found; make sure it's in the scene tree where UI loads.")

	if hearts.size() == 0:
		_update_hearts_display()

	if get_parent() == get_tree().root:
		return

	get_tree().get_root().add_child(self)
	self.owner = null

# -----------------------------------------
# Estado activo/inactivo
# -----------------------------------------
var is_active := false

func activate():
	is_active = true
	visible = true
	set_physics_process(true)
	set_process(true)

	if has_node("Reticle"):
		$Reticle.visible = true

func deactivate():
	is_active = false
	visible = false
	set_physics_process(false)
	set_process(false)

	if has_node("Reticle"):
		$Reticle.visible = false

# -----------------------------------------
# Mostrar corazones
# -----------------------------------------
func _update_hearts_display():
	for heart in hearts:
		if is_instance_valid(heart):
			heart.queue_free()

	hearts.clear()

	for i in range(GameManager.lives):
		var heart := TextureRect.new()
		heart.texture = preload("res://assets/heart_resize.png")
		hearts_container.add_child(heart)
		hearts.append(heart)

# -----------------------------------------
# Sistema general para reproducir sonidos
# -----------------------------------------
func _play_random_sfx(player: AudioStreamPlayer, sounds: Array):
	if sounds.is_empty() or player == null:
		return

	player.stream = sounds[randi() % sounds.size()]
	player.pitch_scale = randf_range(0.97, 1.03)
	player.play()

# -----------------------------------------
# Perder vida
# -----------------------------------------
func remove_heart():
	if GameManager.lives > 0:
		GameManager.lives -= 1
		_update_hearts_display()

		# Si aún quedan vidas → sonido de daño
		if GameManager.lives > 0:
			_play_random_sfx(hurt_sfx, hurt_sounds)

		# Si ya llegó a 0 vidas → sonido de muerte
		else:
			_play_random_sfx(death_sfx, death_sounds)
			await get_tree().create_timer(0.8).timeout

			# Llama al GameOver si lo usas:
			# GameManager.go_to_game_over()

# -----------------------------------------
# Movimiento y cámara
# -----------------------------------------
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.3
		%Camera3D.rotation_degrees.x = clamp(%Camera3D.rotation_degrees.x, -80, 80)
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	# Si está siendo empujado (knockback)
	if is_knockback:
		knockback_timer -= delta
		velocity.y -= 20 * delta
		move_and_slide()

		if knockback_timer <= 0:
			is_knockback = false
		return

	# Movimiento normal
	const SPEED = 5.5
	var input_dir_2d = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir_3d = Vector3(input_dir_2d.x, 0, input_dir_2d.y)
	var direction = transform.basis * dir_3d

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	velocity.y -= 16.0 * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	elif Input.is_action_just_released("jump") and velocity.y > 0:
		velocity.y = 0

	move_and_slide()

	if Input.is_action_pressed("shoot") and %Timer.is_stopped():
		shoot_bullet()

# -----------------------------------------
# Disparo
# -----------------------------------------
func shoot_bullet():
	const BULLET_3D := preload("uid://58tufb0v70ew")
	var new_bullet := BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
	new_bullet.global_transform = %Marker3D.global_transform
	%Timer.start()
	%AudioStreamPlayer.play()

# -----------------------------------------
# Empujón por mob (KNOCKBACK)
# -----------------------------------------
func knockback_from(mob):
	is_knockback = true
	knockback_timer = 0.2

	# --- SONIDO DE EMPUJÓN ---
	if !push_sfx.playing:    # evita saturación si recibes varios empujones seguidos
		push_sfx.stream = push_stream
		push_sfx.pitch_scale = randf_range(0.97, 1.03)
		push_sfx.play()

	var dir = (global_position - mob.global_position)
	dir.y = 0
	dir = dir.normalized()

	var horizontal = dir * 10.0
	var upward = Vector3(0, 4.0, 0)

	velocity = horizontal + upward
