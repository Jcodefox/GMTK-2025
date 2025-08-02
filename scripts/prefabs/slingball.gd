extends CharacterBody2D

@export var max_bounces: int = -1

var animated_sprite_ghosts: Array[Node2D] = []
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
var slingball_held_pos: Vector2 = Vector2.ZERO

var ball_size: int = 0

var lifespan: float = 2
var lasso: Node2D = null

func _ready() -> void:
	slingball_held_pos = global_position
	old_collision_mask = collision_mask
	collision_mask = 0
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSlingball)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	area_shape_ghosts = Globals.make_loop_ghosts_of($Area2D/CollisionShape2D)

	lifespan = [1.5, 2.25, 3.0][ball_size]
	set_animation(["small", "medium", "large"][ball_size])
	set_collision_radius([8, 12, 16][ball_size])
	Globals.make_loop_ghosts_of($WallCheck/CollisionShape2D)

	$Area2D.body_entered.connect(hit_object)

func _process(_delta: float) -> void:
	if still_held:
		return
	if cumulative_delta < lifespan - 0.5:
		visible = true
	elif Globals.do_things_flicker:
		visible = frames_alive % 4 < 2
		frames_alive += 1

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("pull_lasso"):
		still_held = false
		if player != null:
			var pull_direction: Vector2 = Globals.convert_to_visible_pos(global_position).direction_to(Globals.convert_to_visible_pos(player.global_position))
			intended_velocity = pull_direction * ((Globals.convert_to_visible_pos(global_position).distance_to(Globals.convert_to_visible_pos(player.global_position)) / 2.0) + 60)
	if still_held:
		$Area2D.collision_mask = 0
		if lasso != null:
			global_position = Globals.apply_loop_teleport(lasso.lasso_current_pos)
		return
	$Area2D.collision_mask = 4
	if $WallCheck.get_overlapping_bodies().size() == 0:
		collision_mask = old_collision_mask
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
	if cumulative_delta > lifespan and lifespan > -1:
		queue_free()
	
	velocity = intended_velocity

	move_and_slide()

func hit_object(body: Node2D) -> void:
	if still_held:
		return
	if body.is_in_group("enemy") and body.time_alive > body.time_until_enemy_hurts:
		var score: int = body.slingballed(self)
		if score > 0:
			enemies_killed += 1
			Globals.add_score(enemies_killed * score, Globals.convert_to_visible_pos(global_position), get_tree().current_scene, enemies_in_ball)

func set_animation(anim: String) -> void:
	if $AnimatedSlingball.animation != anim:
		$AnimatedSlingball.play(anim)
	
	for sprite in animated_sprite_ghosts:
		if sprite.animation != anim:
			sprite.play(anim)

func set_collision_radius(val: float) -> void:
	$CollisionShape2D.shape.radius = val * 0.75
	$Area2D/CollisionShape2D.shape.radius = val * 1.25
	$WallCheck/CollisionShape2D.shape.radius = val * 0.75
