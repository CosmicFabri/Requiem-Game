extends Node3D

@onready var pickup_sfx: AudioStreamPlayer3D = $PickupSFX

func _ready():
	# Si ya no deben aparecer más corazones, destruye este
	if GameManager.extra_hearts_remaining < 1:
		queue_free()
		return

	# Asignar el sonido al reproductor
	pickup_sfx.stream = preload("res://scenes/heart_pickup/newlife.wav")

	# Animación del corazón
	var animation = %AnimationPlayer
	animation.play("Take 001")

func _on_area_3d_body_entered(body):
	if body == Player:
		# Sumar vida y gastar un corazón extra disponible
		GameManager.lives += 1
		GameManager.extra_hearts_remaining -= 1
		Player._update_hearts_display()

		# Reproducir sonido de pickup
		if pickup_sfx:
			pickup_sfx.play()

		# Opcional: ocultar modelo y colisión mientras suena el audio
		if has_node("Area3D/CollisionShape3D"):
			$"Area3D/CollisionShape3D".disabled = true
		if has_node("MeshInstance3D"):
			$"MeshInstance3D".visible = false

		# Esperar un poco para que el sonido no se corte
		await get_tree().create_timer(0.5).timeout
		queue_free()
