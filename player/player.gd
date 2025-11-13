extends CharacterBody3D

# Persistent state
var spawn_position: Vector3
var hearts = []

@onready var hearts_container = %HeartsContainer

func _ready():
	if hearts_container == null:
		push_warning("HeartsContainer not found; make sure it's in the scene tree where UI loads.")
	
	# Avoid re-initializing hearts if already done (e.g. after changing scenes)
	if hearts.size() == 0:
		_update_hearts_display()
		
	if get_parent() == get_tree().root:
		return
		
	get_tree().get_root().add_child(self)
	self.owner = null # Detach from previous scene

func _update_hearts_display():
	# Remove old hearts
	for heart in hearts:
		if is_instance_valid(heart):
			heart.queue_free()
	hearts.clear()

	# Create new hearts based on GameManager.lives
	for i in range(GameManager.lives):
		var heart = TextureRect.new()
		heart.texture = preload("res://assets/heart_resize.png")
		hearts_container.add_child(heart)
		hearts.append(heart)

func remove_heart():
	if GameManager.lives > 0:
		GameManager.lives -= 1
		_update_hearts_display()

# -----------------------------
# Movement and Camera control
# -----------------------------
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.3
		%Camera3D.rotation_degrees.x = clamp(%Camera3D.rotation_degrees.x, -80.0, 80.0)
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	const SPEED = 5.5
	var input_dir_2d = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir_3d = Vector3(input_dir_2d.x, 0.0, input_dir_2d.y)
	var direction = transform.basis * dir_3d

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	velocity.y -= 20.0 * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()

	if Input.is_action_pressed("shoot") and %Timer.is_stopped():
		shoot_bullet()

func shoot_bullet():
	const BULLET_3D = preload("uid://58tufb0v70ew")
	var new_bullet = BULLET_3D.instantiate()
	%Marker3D.add_child(new_bullet)
	new_bullet.global_transform = %Marker3D.global_transform
	%Timer.start()
	%AudioStreamPlayer.play()
