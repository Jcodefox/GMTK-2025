extends CharacterBody2D

@export var default_gravity: float = 625
@export var air_drag: float = 0.95

@export_group("Horizontal Movement")
@export var ground_lateral_accel: float = 800
@export var ground_lateral_drag: float = 0.0002
@export var air_lateral_accel: float = 0
@export var crouch_lateral_multiplier: float = 0.25

@export_group("Jumping")
@export var jump_init_y_velocity: float = -160
@export var jump_gravity_multiplier: float = 0.6
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
@export var air_jump_init_y_velocity: float = -125
@export var air_jump_init_x_velocity: float = 60

var max_extra_jumps: int = 2
var extra_jumps_left: int = 1
var time_since_on_floor: float = INF
var time_since_jump_attempt: float = INF

func _physics_process(delta: float) -> void:
	handle_edges()
	time_since_on_floor += delta
	time_since_jump_attempt += delta
	
	if Input.is_action_just_pressed("move_jump"):
		time_since_jump_attempt = 0
	if Input.is_action_pressed("move_jump"):
		velocity.y += default_gravity * jump_gravity_multiplier * delta
	else:
		velocity.y += default_gravity * delta
	
	var horizontal_input_axis: float = Input.get_axis("move_left", "move_right")
	var horizontal_accel_multiplier: float = crouch_lateral_multiplier if Input.is_action_pressed("move_down") else 1.0
	if is_on_floor():
		time_since_on_floor = 0
		extra_jumps_left = max_extra_jumps
		velocity.y = 0
		velocity.x += ground_lateral_accel * horizontal_accel_multiplier * horizontal_input_axis * delta
		velocity.x *= pow(ground_lateral_drag, delta)
	else:
		velocity.x += air_lateral_accel * horizontal_accel_multiplier * horizontal_input_axis
		velocity *= pow(air_drag, delta)
	
	if Input.is_action_pressed("move_down"):
		if horizontal_input_axis != 0:
			set_animation("duckwalk")
		else:
			set_animation("duckhide")
	else:
		if velocity.y < 0:
			set_animation("jump")
		else:
			if horizontal_input_axis != 0:
				set_animation("run_right" if horizontal_input_axis > 0 else "run_left")
			else:
				set_animation("idle")
	
	
	if (time_since_on_floor < coyote_time) and (time_since_jump_attempt < jump_buffer_time): # ground jump
		velocity.y = jump_init_y_velocity
		time_since_jump_attempt = INF
	elif (extra_jumps_left > 0) and (time_since_jump_attempt < jump_buffer_time): # air jump
		var direction: float = horizontal_input_axis
		if direction < 0:
			if not velocity.x < -1 * air_jump_init_x_velocity:
				velocity.x = direction * air_jump_init_x_velocity * horizontal_accel_multiplier
		elif direction > 0:
			if not velocity.x > air_jump_init_x_velocity:
				velocity.x = direction * air_jump_init_x_velocity * horizontal_accel_multiplier
		extra_jumps_left -= 1
		velocity.y = air_jump_init_y_velocity
		time_since_jump_attempt = INF
	
	move_and_slide()

func handle_edges() -> void:
	while position.x > 256:
		position.x -= 256
	while position.x < 0:
		position.x += 256

	#while position.y > 256:
	#	position.y -= 256
	#while position.y < 256:
	#	position.y += 256

func set_animation(anim: String) -> void:
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.animation = anim
	$AnimatedSprite2D2.animation = $AnimatedSprite2D.animation
