extends Line2D

@export var min_length: float = 50
@export var closed_margin: float = 5
var mouse_points: PackedVector2Array = []

func _physics_process(delta: float) -> void:
	mouse_points.push_back(get_local_mouse_position())
	points = mouse_points
	while _sum_distance() > 500:
		mouse_points.remove_at(0)
	if _is_closed():
		print("Closed")

func _sum_distance() -> float:
	var sum: float = 0.0
	for i in range(1, mouse_points.size()):
		sum += mouse_points[i].distance_to(mouse_points[i-1])
	return sum

func _inline_distance(a: int, b: int) -> float:
	if a > b:
		var tmp: int = b
		b = a
		a = tmp
	var sum: float = 0.0
	for i in range(a + 1, b):
		sum += mouse_points[i].distance_to(mouse_points[i - 1])
	return sum

func _is_closed() -> bool:
	if _sum_distance() < min_length:
		return false
	if mouse_points.size() == 0:
		return false

	for i in range(0, mouse_points.size() - 1):
		if mouse_points[i].distance_to(mouse_points[mouse_points.size() - 1]) < closed_margin:
			return true

	return false
