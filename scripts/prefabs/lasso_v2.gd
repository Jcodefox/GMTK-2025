extends Line2D

@export var slingball_prefab: PackedScene

@export var min_lasso_capture_size: float = 20.0

@export var max_line_distance: float = 80
@export var max_line_age: float = 0.1

@export var max_mouse_angle_amount: float = 400
@export var max_mouse_angle_age: float = 1.0

@export var minimum_mouse_distance: float = 4.0
@export var gradient_slope: float = 2.0

var line_vertex_positions: PackedVector2Array = []
var line_vertex_time: PackedFloat32Array = []

var lines_mesh_instance: MeshInstance2D = MeshInstance2D.new()
var lines_immediate_mesh: ImmediateMesh = ImmediateMesh.new()

var cumulative_delta: float = 0

var player_pos: Vector2 = Vector2.ZERO

var lasso_loop_size: float = 1
var lasso_target_pos: Vector2 = Vector2.ZERO
var lasso_current_pos: Vector2 = Vector2.ZERO
var last_mouse_pos: Vector2 = Vector2.ZERO

var all_mouse_angles: Array[float] = []
var mouse_angle_time: PackedFloat32Array = []

func _ready():
	lines_mesh_instance.mesh = lines_immediate_mesh
	lines_mesh_instance.name = "LinesMeshInstance"
	lines_mesh_instance.z_index = 4
	get_tree().current_scene.add_child.call_deferred(lines_mesh_instance)

func _process(delta: float):
	cumulative_delta += delta
	
	lasso_target_pos = get_average_line_point()
	lasso_current_pos += (get_global_mouse_position() - lasso_current_pos) / 12.0

	var previous_angle: float = lasso_current_pos.angle_to_point(last_mouse_pos)
	var current_angle: float = lasso_current_pos.angle_to_point(get_global_mouse_position())

	var angle_multiplier: float = clamp((lasso_current_pos.distance_to(get_global_mouse_position()) - minimum_mouse_distance) / gradient_slope, 0.0, 1.0)

	var angle_diff: float = current_angle - previous_angle
	if angle_diff > PI:
		angle_diff = TAU - angle_diff
	if angle_diff < -PI:
		angle_diff = -TAU - angle_diff
	all_mouse_angles.append(angle_diff * angle_multiplier)
	mouse_angle_time.append(cumulative_delta)

	var cumulative_angle: float = abs(all_mouse_angles.reduce(func(acc, val): return acc + val, 0))


	while cumulative_angle > max_mouse_angle_amount:
		all_mouse_angles.remove_at(0)
		mouse_angle_time.remove_at(0)

	for i in mouse_angle_time.size():
		if (cumulative_delta - mouse_angle_time[i]) > max_mouse_angle_age:
			all_mouse_angles.remove_at(0)
			mouse_angle_time.remove_at(0)
		else:
			break

	lasso_loop_size = cumulative_angle * 2.0
	lasso_loop_size = max(lasso_loop_size, 0)

	# Adding a minimum size here prevents issues of collider being too small
	# Which Godot doesn't like (I think)
	$Area2D/CollisionShape2D.shape.radius = max(lasso_loop_size / 2, 0.1)
	$Area2D.position = lasso_current_pos - global_position

	if Input.is_action_just_pressed("pull_lasso"):
		pull_lasso()

	
	var pos: Vector2 = player_pos - global_position

	var new_points: Array[Vector2] = []
	new_points.append(pos)
	var p: int = 20
	for i in range(p + 1):
		var x: float = cos(float(i)/p * TAU + current_angle)
		var y: float = sin(float(i)/p * TAU + current_angle)
		new_points.append(Vector2(x, y) * lasso_loop_size / 2 + lasso_current_pos - global_position)
	points = PackedVector2Array(new_points)
	
	line_vertex_positions.push_back(get_global_mouse_position())
	line_vertex_time.push_back(cumulative_delta)
	while sum_line_distance() > max_line_distance:
		line_vertex_positions.remove_at(0)
		line_vertex_time.remove_at(0)
	for i in line_vertex_time.size():
		if (cumulative_delta - line_vertex_time[i]) > max_line_age:
			line_vertex_positions.remove_at(0)
			line_vertex_time.remove_at(0)
		else:
			break
	draw_lines()
	last_mouse_pos = get_global_mouse_position()

func get_average_line_point() -> Vector2:
	if line_vertex_positions.size() == 0:
		return Vector2.ZERO

	var sum: Vector2 = Vector2.ZERO
	for point in line_vertex_positions:
		sum += point
	return sum / line_vertex_positions.size()

func sum_line_distance(start_index: int = 0, count: int = -1) -> float:
	var sum: float = 0.0
	if count == -1:
		count = (line_vertex_positions.size() - start_index) - 1
	for i in range(start_index, start_index + count, 1):
		sum += line_vertex_positions[i].distance_to(line_vertex_positions[i-1])
	return sum

func draw_lines():
	# Prevent trying to draw lines with less than 2 points
	if line_vertex_positions.size() < 2:
		return
	lines_immediate_mesh.clear_surfaces()
	lines_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for i in range(0, line_vertex_positions.size() - 1):
		lines_immediate_mesh.surface_set_color(Color.from_hsv(line_vertex_time[i] / 2.5, 0.1, 
		1.0 - (0.3 * ((cumulative_delta - line_vertex_time[i]) / max_line_age)) ))
		lines_immediate_mesh.surface_add_vertex_2d(line_vertex_positions[i])
		lines_immediate_mesh.surface_add_vertex_2d(line_vertex_positions[i + 1])
	lines_immediate_mesh.surface_end()

func pull_lasso() -> void:
	if lasso_loop_size < min_lasso_capture_size:
		return

	var killed_enemies: int = 0

	all_mouse_angles.clear()
	mouse_angle_time.clear()

	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			killed_enemies += 1
			body.queue_free()
	
	if killed_enemies > 0:
		var points: int = killed_enemies * 10
		Globals.add_score(points, Globals.convert_to_visible_pos(lasso_current_pos), get_tree().current_scene)
		var pull_direction: Vector2 = Globals.convert_to_visible_pos(lasso_current_pos).direction_to(Globals.convert_to_visible_pos(global_position))
		var new_slingball: Node2D = slingball_prefab.instantiate()
		new_slingball.enemies_in_ball = killed_enemies
		new_slingball.global_position = Globals.convert_to_visible_pos(lasso_current_pos)
		new_slingball.intended_velocity = pull_direction * 100
		get_tree().current_scene.add_child(new_slingball)
