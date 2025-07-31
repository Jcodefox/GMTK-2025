extends Node

var world_top_left: Vector2 = Vector2(8, 24)
var world_bottom_right: Vector2 = Vector2(248, 184)

@onready var world_dimensions: Vector2 = (world_top_left - world_bottom_right).abs()

func _process(delta):
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

	ghosts[0].position.x = -world_dimensions.x
	ghosts[1].position = -world_dimensions
	ghosts[2].position.y = -world_dimensions.y

	var original_parent: Node2D = obj.get_parent()
	original_parent.add_child(ghosts[0])
	original_parent.add_child(ghosts[1])
	original_parent.add_child(ghosts[2])
	return ghosts
