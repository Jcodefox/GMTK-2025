extends Enemy

@export var min_time_to_appear: float = 0
@export var max_time_to_appear: float = 0
@export var bubble_lifespan: float = 10
@export var speed: float = 25
@export var spawn_points: Array[Vector2] = []
@export var spawn_move_left: Array[bool] = []

var intended_direction: Vector2 = Vector2.ZERO
var ball_type: int = 0

func _ready() -> void:
	time_until_enemy_hurts = 0
	
	collision_mask = 0
	collision_layer = 0
	visible = false
	dead = true
	
	get_tree().create_timer(randf_range(min_time_to_appear, max_time_to_appear)).timeout.connect(appear)

func _physics_process(delta: float) -> void:
	if dead:
		return
	super(delta)
	
	if is_on_wall():
		intended_direction.x = -intended_direction.x
	if is_on_ceiling() or is_on_floor():
		intended_direction.y = -intended_direction.y

	velocity = intended_direction * speed
	
	move_and_slide()
			
func slingballed(_ball: Node2D) -> int:
	die()
	return [50, 50, 50][ball_type]

func die() -> void:
	dead = true
	collision_mask = 0
	collision_layer = 0
	set_animation("death")
	await get_tree().create_timer(0.5).timeout
	visible = false
	get_tree().create_timer(randf_range(min_time_to_appear, max_time_to_appear)).timeout.connect(appear)

func appear() -> void:
	visible = true
	dead = false
	time_alive = 0
	
	if spawn_points.size() != 0:
		var choice: int = randi_range(0, spawn_points.size() - 1)
		global_position = spawn_points[choice]
		intended_direction = Vector2(-1 if spawn_move_left[choice] else 1, [-1, 1].pick_random()).normalized()
	else:
		intended_direction = [Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1)].pick_random().normalized()
	collision_mask = 2
	collision_layer = 4
	var options: Array[int] = [2]
	if Globals.player != null:
		if Globals.player.extra_health:
			options.push_back(1)
		if Globals.player.max_extra_jumps == 0:
			options.push_back(0)
	ball_type = options.pick_random()
	set_animation(["boot", "hat", "points"][ball_type])
