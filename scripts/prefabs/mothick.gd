extends CharacterBody2D

var animated_sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []

func _ready() -> void:
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)

func _physics_process(delta: float) -> void:
	global_position = Globals.apply_loop_teleport(global_position)
	for sprite in animated_sprite_ghosts:
		sprite.animation = $AnimatedSprite2D.animation

	velocity.x += randf_range(-1.0, 1.0)
	velocity.y += randf_range(-1.0, 1.0)
	velocity = velocity.clamp(Vector2(-10.0, -10.0), Vector2(10.0, 10.0))
	
	move_and_slide()
