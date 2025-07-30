extends Line2D

var mouse_points: PackedVector2Array = []

func _physics_process(delta: float) -> void:
	mouse_points.push_back(get_global_mouse_position())
	points = mouse_points
