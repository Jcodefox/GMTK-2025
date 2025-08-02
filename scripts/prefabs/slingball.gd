extends CharacterBody2D

@export var max_bounces: int = -1
@export var max_lifetime: float = 2
@export var flashing_start_time: float = 1.5

var sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var area_shape_ghosts: Array[Node2D] = []

var intended_velocity: Vector2 = Vector2.ZERO

var bounces: int = 0
var cumulative_delta: float = 0

var enemies_in_ball: int = 0
var enemies_killed: int = 0
var frames_alive: int = 0

var player: Node2D = null
var still_held: bool = true
var old_collision_mask: int = 0

func _ready() -> void:
	old_collision_mask = collision_mask
	collision_mask = 0
	sprite_ghosts = Globals.make_loop_ghosts_of($SuspiciousPlaceholderSlingball)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	area_shape_ghosts = Globals.make_loop_ghosts_of($Area2D/CollisionShape2D)

	Globals.make_loop_ghosts_of($WallCheck/CollisionShape2D)

	$Area2D.body_entered.connect(hit_object)

func _process(_delta: float) -> void:
	if still_held:
		return
	if cumulative_delta < flashing_start_time:
		visible = true
	elif Globals.do_things_flicker:
		visible = frames_alive % 4 < 2
		frames_alive += 1

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("pull_lasso"):
		still_held = false
		if player != null:
			var pull_direction: Vector2 = Globals.convert_to_visible_pos(global_position).direction_to(Globals.convert_to_visible_pos(player.global_position))
			intended_velocity = pull_direction * 100
	if still_held:
		global_position = get_global_mouse_position()
		global_position = Globals.apply_loop_teleport(global_position)
		return
	if $WallCheck.get_overlapping_bodies().size() == 0:
		collision_mask = old_collision_mask
	cumulative_delta += delta
	#update_disappear_blink()
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
	if still_held:
		return
	if body.is_in_group("enemy") and body.time_alive > body.time_until_enemy_hurts:
		enemies_killed += 1
		Globals.add_score(enemies_killed * 10, Globals.convert_to_visible_pos(global_position), get_tree().current_scene, enemies_in_ball)
		body.queue_free()

func update_disappear_blink() -> void:
	if cumulative_delta < flashing_start_time or not Globals.do_things_flicker:
		visible = true
		return
	visible = int(cumulative_delta * 8) % 2 < 1
