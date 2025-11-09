extends Node3D

signal mob_spawned(mob)

@export var mob_to_spawn: PackedScene = null

@onready var marker_3d = %Marker3D
@onready var timer = %Timer

var mobs_spawned = 0

func _on_timer_timeout():
	if mobs_spawned >= 3:
		return
	
	var new_mob = mob_to_spawn.instantiate()
	add_child(new_mob)
	new_mob.global_position = marker_3d.global_position
	mob_spawned.emit(new_mob) # Emit the signal
	mobs_spawned += 1
