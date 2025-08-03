extends Enemy

@export var pop_audio: AudioStream
@export var min_time_to_appear: float = 90
@export var max_time_to_appear: float = 270
@export var bounce_force_min: float = 200
@export var bounce_force_max: float = 250
@export var speed: float = 32
@export var spawn_points: Array[Vector2] = []
@export var spawn_move_left: Array[bool] = []

var intended_direction: float = 1

func _ready() -> void:
	time_until_enemy_hurts = 0
	die(0, false)
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if dead:
		return
	super(delta)
	die_outside_world()
	
	velocity.y += default_gravity * delta
	
	if is_on_wall():
		die()
	if is_on_floor():
		velocity.y = randf_range(-bounce_force_min, -bounce_force_max)

	velocity.x = intended_direction * speed
	
	move_and_slide()
	
func lassod() -> int:
	queue_free()
	return 100
			
func slingballed(_ball: Node2D, ith_enemy: int = 0) -> int:
	die()
	return 100

func die(enemy_multiplier: int = 0, animate: bool = true) -> void:
	dead = true
	collision_mask = 0
	collision_layer = 0
	if animate:
		playsound(pop_audio, true)
		$AudioStreamPlayer.volume_linear = 0.3
		set_animation("death")
		visible = false
		await get_tree().create_timer(0.5).timeout
	get_tree().create_timer(randf_range(min_time_to_appear, max_time_to_appear)).timeout.connect(appear)

func die_outside_world() -> void:
	if global_position.x < Globals.world_top_left.x - 9:
		die(0, false)
	if global_position.y < Globals.world_top_left.y - 9:
		die(0, false)
	if global_position.x > Globals.world_bottom_right.x + 9:
		die(0, false)
	if global_position.y > Globals.world_bottom_right.y + 9:
		die(0, false)

func appear() -> void:
	visible = true
	dead = false
	time_alive = -1
	
	if spawn_points.size() != 0:
		var choice: int = randi_range(0, spawn_points.size() - 1)
		global_position = spawn_points[choice]
		intended_direction = -1 if spawn_move_left[choice] else 1
	else:
		intended_direction = [-1, 1].pick_random()
	velocity.y = randf_range(-bounce_force_min, -bounce_force_max)
	collision_mask = 2
	collision_layer = 4
	
func playsound(audio: AudioStream, force: bool = false) -> void:
	if $AudioStreamPlayer.playing and $AudioStreamPlayer.stream == audio and not force:
		return
	$AudioStreamPlayer.volume_linear = 1.0
	$AudioStreamPlayer.stream = audio
	$AudioStreamPlayer.play()
