extends CharacterBody3D

var spawn_position: Vector3

func _ready():
	# Remember initial position as spawn
	spawn_position = global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func respawn():
	# Optionally reset health or other stats here
	global_position = spawn_position
	velocity = Vector3.ZERO

# Control the rotation of the character/camera
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.3
		%Camera3D.rotation_degrees.x = clamp(
			%Camera3D.rotation_degrees.x, -80.0, 80.0
		)
	elif event.is_action_pressed("ui_cancel"):
		# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()

func _physics_process(delta):
	const SPEED = 5.5 # meters / second
	
	# Setting up the direction of the character
	var input_direction_2D = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var input_direction_3D = Vector3(
		input_direction_2D.x, 0.0, input_direction_2D.y
	)
	var direction = transform.basis * input_direction_3D
	
	# Velocity in the 2D (X, Z) plane
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
	velocity.y -= 20.0 * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0
	
	# Move the character every frame
	move_and_slide()
	
	if Input.is_action_pressed("shoot") and %Timer.is_stopped():
		shoot_bullet()
	
func shoot_bullet():
	# Load bullet scene from the filesystem
	const BULLET_3D = preload("uid://58tufb0v70ew")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
	
	# Move, rotate and scale the bullet as the marker
	new_bullet.global_transform = %Marker3D.global_transform
	
	%Timer.start()
	%AudioStreamPlayer.play()
