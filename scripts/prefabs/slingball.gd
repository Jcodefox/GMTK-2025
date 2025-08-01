extends CharacterBody2D

var sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var area_shape_ghosts: Array[Node2D] = []

var intended_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	sprite_ghosts = Globals.make_loop_ghosts_of($SuspiciousPlaceholderSlingball)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	area_shape_ghosts = Globals.make_loop_ghosts_of($Area2D/CollisionShape2D)

	$Area2D.body_entered.connect(hit_object)

func _physics_process(delta: float) -> void:
	global_position = Globals.apply_loop_teleport(global_position)

	if is_on_wall():
		intended_velocity.x = -intended_velocity.x
	if is_on_ceiling() or is_on_floor():
		intended_velocity.y = -intended_velocity.y
	
	velocity = intended_velocity

	move_and_slide()

func hit_object(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		print("Kill")
		body.queue_free()
