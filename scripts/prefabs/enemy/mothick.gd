extends CharacterBody2D

var animated_sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var jump_check_shape_ghosts: Array[Node2D] = []
var time_alive: float = 0

func _ready() -> void:
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	jump_check_shape_ghosts = Globals.make_loop_ghosts_of($JumpOverCheck/CollisionShape2D)

func _physics_process(delta: float) -> void:
	time_alive += delta
	global_position = Globals.apply_loop_teleport(global_position)
	for sprite in animated_sprite_ghosts:
		sprite.animation = $AnimatedSprite2D.animation

	if is_on_wall():
		velocity.x = -velocity.x
	if is_on_ceiling() or is_on_floor():
		velocity.y = -velocity.y
	velocity.x += randf_range(-3.0, 3.0)
	velocity.y += randf_range(-3.0, 3.0)
	velocity = velocity.normalized() * 25
	
	move_and_slide()
