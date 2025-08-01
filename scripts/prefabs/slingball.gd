extends CharacterBody2D

@export var max_bounces: int = 5
@export var max_lifetime: float = -1

var sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var area_shape_ghosts: Array[Node2D] = []

var intended_velocity: Vector2 = Vector2.ZERO

var bounces: int = 0
var cumulative_delta: float = 0

func _ready() -> void:
	sprite_ghosts = Globals.make_loop_ghosts_of($SuspiciousPlaceholderSlingball)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	area_shape_ghosts = Globals.make_loop_ghosts_of($Area2D/CollisionShape2D)

	$Area2D.body_entered.connect(hit_object)

func _physics_process(delta: float) -> void:
	cumulative_delta += delta
	global_position = Globals.apply_loop_teleport(global_position)

	if is_on_wall():
		intended_velocity.x = -intended_velocity.x
		bounces += 1
	if is_on_ceiling() or is_on_floor():
		intended_velocity.y = -intended_velocity.y
		bounces += 1
	
	if bounces > max_bounces and max_bounces > -1:
		queue_free()
	if cumulative_delta > max_lifetime and max_lifetime > -1:
		queue_free()
	
	velocity = intended_velocity

	move_and_slide()

func hit_object(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.queue_free()
