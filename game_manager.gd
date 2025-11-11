extends Node

var score = 0

var levels = [
	"res://scenes/level_1/level_1.tscn",
	"res://scenes/level_2/level_2.tscn",
	"res://scenes/level_3/level_3.tscn"
]

var current_level_index = 0

func load_level(index):
	if index < 0 or index >= levels.size():
		return
	var scene = load(levels[index])
	var level_instance = scene.instantiate()
	get_tree().root.add_child(level_instance)
	current_level_index = index

func next_level():
	var next_index = (current_level_index + 1) % levels.size()
	get_tree().change_scene_to_file(levels[next_index])
