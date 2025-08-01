extends Node

var world_top_left: Vector2 = Vector2(8, 24)
var world_bottom_right: Vector2 = Vector2(248, 184)

var lives: int = 3
var time_passed: float = 0
var score: int = 0

var high_score: int = 0

@onready var world_dimensions: Vector2 = (world_top_left - world_bottom_right).abs()
@onready var float_score_num: PackedScene = preload("res://scenes/prefabs/float_score_num.tscn")

var player: Node2D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_high_score()

func _process(delta):
	if not get_tree().paused:
		time_passed += delta
	if Input.is_action_just_pressed("fullscreen_toggle"):
		if not DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func apply_loop_teleport(pos: Vector2) -> Vector2:
	var world_center: Vector2 = (world_dimensions / 2.0) + world_top_left
	return (pos - world_center).posmodv(world_dimensions) + world_center

func convert_to_visible_pos(pos: Vector2) -> Vector2:
	return (pos - world_top_left).posmodv(world_dimensions) + world_top_left

func make_loop_ghosts_of(obj: Node2D) -> Array[Node2D]:
	var ghosts: Array[Node2D] = []
	ghosts.push_back(obj.duplicate())
	ghosts.push_back(obj.duplicate())
	ghosts.push_back(obj.duplicate())

	ghosts[0].position.x = obj.position.x - world_dimensions.x
	ghosts[1].position = obj.position - world_dimensions
	ghosts[2].position.y = obj.position.y - world_dimensions.y

	var original_parent: Node2D = obj.get_parent()
	original_parent.add_child(ghosts[0])
	original_parent.add_child(ghosts[1])
	original_parent.add_child(ghosts[2])
	return ghosts


func add_score(score_to_add: int, position: Vector2, parent: Node2D) -> void:
	score += score_to_add
	
	var score_to_display = float_score_num.instantiate()
	score_to_display.point_value = score_to_add*10
	parent.add_child(score_to_display)
	score_to_display.set_position(position)

var tween: Tween

func game_over() -> void:
	var new_score: int = score + int(time_passed)

	if new_score > high_score:
		high_score = new_score
		save_high_score()

	tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(self, "time_passed", 0, 1)
	tween.parallel().tween_property(self, "score", new_score, 1)
	await tween.finished

func reset_game() -> void:
	tween.stop()
	lives = 3
	time_passed = 0
	score = 0
	get_tree().paused = false
	await get_tree().process_frame
	get_tree().reload_current_scene()

func save_high_score() -> void:
	var config = ConfigFile.new()
	config.set_value("Player", "high_score", high_score)
	config.save("user://high_score.cfg")

func load_high_score() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err = config.load("user://high_score.cfg")
	if err != OK:
		return
	high_score = config.get_value("Player", "high_score")
