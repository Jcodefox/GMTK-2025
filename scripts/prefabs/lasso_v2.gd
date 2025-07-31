extends Line2D

@export var max_line_distance: float = 400
@export var max_line_age: float = 1.0
var line_vertex_positions: PackedVector2Array = []
var line_vertex_time: PackedFloat32Array = []

var lines_mesh_instance: MeshInstance2D = MeshInstance2D.new()
var lines_immediate_mesh: ImmediateMesh = ImmediateMesh.new()

var cumulative_delta: float = 0

var player_pos: Vector2 = Vector2.ZERO

func _ready():
	lines_mesh_instance.mesh = lines_immediate_mesh
	lines_mesh_instance.name = "LinesMeshInstance"
	lines_mesh_instance.z_index = 4
	get_tree().current_scene.add_child.call_deferred(lines_mesh_instance)

func _process(delta: float):
	cumulative_delta += delta
	
	points = PackedVector2Array([global_position - player_pos, get_local_mouse_position()])
	
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
