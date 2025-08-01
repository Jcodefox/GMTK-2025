extends CharacterBody2D

@export var speed: float = 15

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

	var desired_direction: Vector2 = Vector2.ZERO
	if Globals.player != null and Globals.player.is_inside_tree():
		desired_direction = Globals.convert_to_visible_pos(global_position).direction_to(Globals.convert_to_visible_pos(Globals.player.global_position))
	if desired_direction == Vector2.ZERO:
		set_animation("idle")
	else:
		set_animation("right" if desired_direction.x > 0 else "left")
	
	velocity += desired_direction
	velocity = velocity.normalized() * speed
	
	move_and_slide()

func set_animation(anim: String) -> void:
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)
	
	for sprite in animated_sprite_ghosts:
		if sprite.animation != anim:
			sprite.play(anim)
