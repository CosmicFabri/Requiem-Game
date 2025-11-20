extends Node

var score = 0
var lives = 3
var high_score = 0
var extra_hearts_remaining = 3
const SAVE_PATH = "user://save_data.json"

var levels = [
	"res://scenes/level_1/level_1.tscn",
	"res://scenes/level_2/level_2.tscn",
	"res://scenes/level_boss_1/LevelBoss1.tscn",
	"res://scenes/level_3/level_3.tscn",
]

var current_level_index = 0

func _ready():
	load_high_score()

func load_level(index):
	if index < 0 or index >= levels.size():
		return

	# Load and add the level
	var scene = load(levels[index])
	var level_instance = scene.instantiate()
	get_tree().root.add_child(level_instance)
	current_level_index = index
	
func next_level():
	var next_index = (current_level_index + 1) % levels.size()
	current_level_index = next_index
	get_tree().change_scene_to_file(levels[next_index])
	
func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	
func go_to_game_over():
	call_deferred("_change_to_game_over")

func _change_to_game_over():
	get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY and data.has("high_score"):
			high_score = int(data["high_score"])
		file.close()
	else:
		high_score = 0
		
func update_high_score():
	if score > high_score:
		high_score = score
		save_high_score()
		
func save_high_score():
	var data = {"high_score": high_score}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
