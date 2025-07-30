extends CharacterBody2D

@export var default_gravity: float = 500
@export var air_drag: float = 0.95

@export_group("Horizontal Movement")
@export var ground_lateral_accel: float = 800
@export var ground_lateral_drag: float = 0.0002
@export var air_lateral_accel: float = 0

@export_group("Jumping")
@export var jump_init_y_velocity: float = -200
@export var jump_gravity_multiplier: float = 0.6
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
@export var air_jump_init_y_velocity: float = -150
@export var air_jump_init_x_velocity: float = 60

var max_extra_jumps: int = 2
var extra_jumps_left: int = 1
var time_since_on_floor: float = INF
var time_since_jump_attempt: float = INF

func _physics_process(delta: float) -> void:
	time_since_on_floor += delta
	time_since_jump_attempt += delta
	
	if Input.is_action_just_pressed("move_jump"):
		time_since_jump_attempt = 0
	if Input.is_action_pressed("move_jump"):
		velocity.y += default_gravity * jump_gravity_multiplier * delta
	else:
		velocity.y += default_gravity * delta
	
	if is_on_floor():
		time_since_on_floor = 0
		extra_jumps_left = max_extra_jumps
		velocity.y = 0
		velocity.x += ground_lateral_accel * Input.get_axis("move_left", "move_right") * delta
		velocity.x *= pow(ground_lateral_drag, delta)
	else:
		velocity.x += air_lateral_accel * Input.get_axis("move_left", "move_right")
		velocity *= pow(air_drag, delta)
	
	if (time_since_on_floor < coyote_time) and (time_since_jump_attempt < jump_buffer_time): # ground jump
		velocity.y = jump_init_y_velocity
		time_since_jump_attempt = INF
	elif (extra_jumps_left > 0) and (time_since_jump_attempt < jump_buffer_time): # air jump
		var direction: float = Input.get_axis("move_left", "move_right")
		if direction < 0:
			if not velocity.x < -1 * air_jump_init_x_velocity:
				velocity.x = direction * air_jump_init_x_velocity
		elif direction > 0:
			if not velocity.x > air_jump_init_x_velocity:
				velocity.x = direction * air_jump_init_x_velocity
		extra_jumps_left -= 1
		velocity.y = air_jump_init_y_velocity
		time_since_jump_attempt = INF
	
	move_and_slide()
