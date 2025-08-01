extends CharacterBody2D

@export var time_until_enemy_hurts: float = 1.0
@export var default_gravity: float = 625

var animated_sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var jump_check_shape_ghosts: Array[Node2D] = []

var intended_direction: float = 1.0

var time_alive: float = 0.0

func _ready() -> void:
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	jump_check_shape_ghosts = Globals.make_loop_ghosts_of($JumpOverCheck/CollisionShape2D)

func _physics_process(delta: float) -> void:
	time_alive += delta
	update_i_frames()
	global_position = Globals.apply_loop_teleport(global_position)
	$AnimatedSprite2D.flip_h = intended_direction > 0
	for sprite in animated_sprite_ghosts:
		sprite.animation = $AnimatedSprite2D.animation
		sprite.flip_h = intended_direction > 0

	if is_on_wall():
		intended_direction = -intended_direction
	velocity.y += default_gravity * delta
	velocity.x = intended_direction * 25
	
	move_and_slide()

func update_i_frames() -> void:
	if time_alive >= time_until_enemy_hurts:
		visible = true
		return
	visible = int(time_alive * 8) % 2 < 1
