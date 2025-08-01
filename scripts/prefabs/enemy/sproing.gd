extends CharacterBody2D

@export var default_gravity: float = 625
@export var min_start_crouch_time: float = 0.5
@export var max_start_crouch_time: float = 2.5
@export var crouch_time_length: float = 1.0
@export var jump_force: float = 200.0
@export var jump_x_component: float = 30.0

var animated_sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var jump_check_shape_ghosts: Array[Node2D] = []

var intended_direction: float = 1.0

var time_alive: float = 0.0
var time_on_ground: float = 0.0
var chosen_crouch_time: float = 0.0

func _ready() -> void:
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	jump_check_shape_ghosts = Globals.make_loop_ghosts_of($JumpOverCheck/CollisionShape2D)

func _physics_process(delta: float) -> void:
	time_alive += delta
	global_position = Globals.apply_loop_teleport(global_position)

	if is_on_floor():
		if time_on_ground == 0.0:
			chosen_crouch_time = randf_range(min_start_crouch_time, max_start_crouch_time)
		time_on_ground += delta
		velocity.x = 0.0
	else:
		time_on_ground = 0.0
	
	if time_on_ground >= chosen_crouch_time:
		set_animation("duck")
	if time_on_ground >= chosen_crouch_time + crouch_time_length:
		set_animation("jump")
		velocity.y = -jump_force
		velocity.x = [jump_x_component, -jump_x_component].pick_random()

	velocity.y += default_gravity * delta
	
	move_and_slide()

func set_animation(anim: String) -> void:
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)
	
	for sprite in animated_sprite_ghosts:
		if sprite.animation != anim:
			sprite.play(anim)
