extends CharacterBody2D

@export var game_over_screen: Node

@export var default_gravity: float = 625
@export var air_drag: float = 0.95

@export_group("Horizontal Movement")
@export var ground_lateral_accel: float = 450
@export var ground_lateral_drag: float = 0.0002
@export var air_lateral_accel: float = 0.25
@export var crouch_lateral_multiplier: float = 0.25

@export_group("Jumping")
@export var jump_init_y_velocity: float = -160
@export var jump_gravity_multiplier: float = 0.6
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
@export var air_jump_init_y_velocity: float = -125
@export var air_jump_init_x_velocity: float = 60
@export var terminal_fall_velocity: float = 275

var max_extra_jumps: int = 1
var extra_jumps_left: int = 0
var time_since_on_floor: float = INF
var time_since_jump_attempt: float = INF
var jump_over_combo = 1

var animated_sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var hurtbox_shape_ghosts: Array[Node2D] = []
var all_shape_ghosts_original_poses: PackedVector2Array = []

@onready var hitbox_original_pos: Vector2 = Vector2.ZERO

var visual_facing_left: bool = false
# Used to prevent player input when playing death animation
var dead: bool = false
var dead_hat_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	Globals.player = self
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	hurtbox_shape_ghosts = Globals.make_loop_ghosts_of($HurtBox/CollisionShape2D)
	hitbox_original_pos = $CollisionShape2D.position
	for shape in collision_shape_ghosts:
		all_shape_ghosts_original_poses.append(shape.position)

	$HurtBox.body_entered.connect(area_hit_body)
	$HurtBox.area_exited.connect(area_exited_area)

func _physics_process(delta: float) -> void:
	if dead:
		velocity.y += default_gravity * delta
		$Hat.position += dead_hat_velocity * delta
		move_and_slide()
		return 

	global_position = Globals.apply_loop_teleport(global_position)
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
		jump_over_combo = 1
		velocity.y = 0
		velocity.x += ground_lateral_accel * horizontal_accel_multiplier * horizontal_input_axis * delta
		velocity.x *= pow(ground_lateral_drag, delta)
	else:
		velocity.x += air_lateral_accel * horizontal_accel_multiplier * horizontal_input_axis
		velocity *= pow(air_drag, delta)
	
	if horizontal_input_axis != 0:
		visual_facing_left = horizontal_input_axis < 0
	
	if Input.is_action_just_pressed("move_down"):
		set_collision_height(9, 2.5)
	if Input.is_action_just_released("move_down"):
		set_collision_height(14, 0)
	
	if Input.is_action_pressed("move_down"):
		if horizontal_input_axis != 0:
			set_animation("duckwalk")
		else:
			set_animation("duckhide")
	else:
		if velocity.y < 0:
			set_animation("jump_left" if visual_facing_left else "jump_right")
		elif velocity.y > 0:
			set_animation("fall_left" if visual_facing_left else "fall_right")
		else:
			if horizontal_input_axis != 0:
				set_animation("run_left" if visual_facing_left else "run_right")
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
	
	velocity.y = minf(velocity.y, terminal_fall_velocity)
	
	move_and_slide()
	$Lasso.player_pos = Globals.convert_to_visible_pos(global_position)

func area_hit_body(body: Node2D) -> void:
	if dead:
		return
	if body.is_in_group("enemy") and body.time_alive > body.time_until_enemy_hurts:
		dead = true
		Globals.lives -= 1
		set_animation("death")

		# Hide all invisible players that are above screen
		var on_screen_pos: Vector2 = Globals.convert_to_visible_pos(global_position)
		if $AnimatedSprite2D.global_position.y != on_screen_pos.y:
			$AnimatedSprite2D.visible = false
		for sprite in animated_sprite_ghosts:
			if sprite.global_position.y != on_screen_pos.y:
				sprite.visible = false

		$Hat.visible = true
		$Hat.position += on_screen_pos - global_position
		dead_hat_velocity = Vector2(randf_range(-15.0, 15.0), -50)

		$Lasso.visible = false

		# Disable collision so you can fall out of world
		collision_mask = 0
		collision_layer = 0
		
		# Make character bounce upward
		velocity = Vector2(0, -100)

		get_tree().paused = true
		if Globals.lives > 0:
			get_tree().create_timer(2).timeout.connect(
				func():
					get_tree().paused = false
					await get_tree().process_frame
					get_tree().reload_current_scene()
			)
		else:
			get_tree().create_timer(2).timeout.connect(
				func():
					if game_over_screen != null:
						game_over_screen.visible = true
					Globals.game_over()
			)
		
func area_exited_area(area: Area2D) -> void:
	if dead:
		return
	var parent: Node2D = area.get_parent()
	if (area.name == "JumpOverCheck" and parent.time_alive > parent.time_until_enemy_hurts):
		Globals.add_score(jump_over_combo * 1, Globals.convert_to_visible_pos(area.global_position), $"..")
		jump_over_combo += 1

func set_animation(anim: String) -> void:
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.animation = anim
	for sprite in animated_sprite_ghosts:
		sprite.animation = $AnimatedSprite2D.animation

func set_collision_height(amount: float, offset: float) -> void:
	$CollisionShape2D.shape.size.y = amount
	$CollisionShape2D.position.y = hitbox_original_pos.y + offset

	$HurtBox/CollisionShape2D.shape.size.y = amount
	$HurtBox/CollisionShape2D.position.y = hitbox_original_pos.y + offset

	for i in range(all_shape_ghosts_original_poses.size()):
		collision_shape_ghosts[i].position.y = all_shape_ghosts_original_poses[i].y + offset
		hurtbox_shape_ghosts[i].position.y = all_shape_ghosts_original_poses[i].y + offset
		
