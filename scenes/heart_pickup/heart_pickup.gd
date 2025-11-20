extends Node3D

func _ready():
	if GameManager.extra_hearts_remaining < 1:
		queue_free()
		return
	
	var animation = %AnimationPlayer
	animation.play("Take 001")

func _on_area_3d_body_entered(body):
	if body == Player:
		GameManager.lives += 1
		GameManager.extra_hearts_remaining -= 1
		Player._update_hearts_display()
		queue_free()
