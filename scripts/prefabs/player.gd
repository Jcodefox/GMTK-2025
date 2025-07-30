extends CharacterBody2D

@export var move_speed: float = 200

@export_group("Drag")
@export var infinite_air_drag: bool = false
@export var air_drag: float = 500

@export var infinite_ground_drag: bool = true
@export var ground_drag: float = 500

@export_group("Jumping")
@export var jump_force: float = 500
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
@export var max_jump_held_time: float = 1.0

@export_range(0, 100) var double_jumps: int = 1

@export_group("Gravity")
@export var jump_gravity: float = 980
@export var terminal_velocity: float = 100.0

var jump_held_time: float = INF
var last_jump_attempt: float = INF
var last_on_floor: float = INF
@onready var double_jumps_left: int = double_jumps

func _physics_process(delta: float) -> void:
	var gravity_strength: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 2.5

	var current_gravity = jump_gravity if jump_held_time < max_jump_held_time else gravity_strength
	
	if not is_on_floor():
		velocity.y += current_gravity * delta
	velocity.y = min(velocity.y, terminal_velocity)

	var direction: float = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * move_speed
	elif not is_on_floor() and not infinite_air_drag:
		velocity.x = move_toward(velocity.x, 0, delta * air_drag)
	elif is_on_floor() and not infinite_ground_drag:
		velocity.x = move_toward(velocity.x, 0, delta * ground_drag)
	else:
		velocity.x = 0

	# Keep track of these for coyote time and jump buffering
	last_jump_attempt += delta
	last_on_floor += delta

	if is_on_floor():
		last_on_floor = 0
		# We do one above, because the jump off the floor uses one double jump (simpler that way)
		double_jumps_left = double_jumps + 1

	if Input.is_action_just_pressed("move_jump"):
		last_jump_attempt = 0
	
	if Input.is_action_pressed("move_jump"):
		jump_held_time += delta
	else:
		# Halt jump gravity
		jump_held_time = INF
	
	if last_jump_attempt < coyote_time and (last_on_floor < jump_buffer_time or double_jumps_left > 0):
		velocity.y = -jump_force
		double_jumps_left = max(double_jumps_left - 1, 0)
		jump_held_time = 0
		# This prevents all double jumps from executing at once
		last_jump_attempt = INF
	

	move_and_slide()

