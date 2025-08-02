extends CharacterBody2D

@export var time_until_enemy_hurts: float = 1.0

@export var default_gravity: float = 625
@export var min_start_crouch_time: float = 0.5
@export var max_start_crouch_time: float = 2.5
@export var crouch_time_length: float = 1.0
@export var jump_force: float = 200.0
@export var jump_x_component: float = 30.0

var animated_sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var jump_check_shape_ghosts: Array[Node2D] = []

var all_shape_ghosts_original_poses: PackedVector2Array = []

@onready var hitbox_original_pos: Vector2 = Vector2.ZERO

var intended_direction: float = 1.0

var time_alive: float = 0.0
var time_on_ground: float = 0.0
var chosen_crouch_time: float = 0.0

var frames_alive: int = 0

func _ready() -> void:
	chosen_crouch_time = randf_range(min_start_crouch_time, max_start_crouch_time)
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	jump_check_shape_ghosts = Globals.make_loop_ghosts_of($JumpOverCheck/CollisionShape2D)
	hitbox_original_pos = $CollisionShape2D.position
	for shape in collision_shape_ghosts:
		all_shape_ghosts_original_poses.append(shape.position)

func _process(_delta: float) -> void:
	if time_alive > time_until_enemy_hurts:
		visible = true
	elif Globals.do_things_flicker:
		visible = frames_alive % 4 < 2
		frames_alive += 1

func _physics_process(delta: float) -> void:
	time_alive += delta
	#Globals.update_enemy_i_frames(self)
	global_position = Globals.apply_loop_teleport(global_position)

	if is_on_floor():
		if time_on_ground == 0.0:
			chosen_crouch_time = randf_range(min_start_crouch_time, max_start_crouch_time)
		time_on_ground += delta
		velocity.x = 0.0
	else:
		time_on_ground = 0.0
	
	if time_on_ground >= chosen_crouch_time:
		set_animation("duck", ((time_on_ground - chosen_crouch_time) / crouch_time_length) + 1)
		set_collision_height(8, 3)
	else:
		set_collision_height(14, 0)
	if time_on_ground >= chosen_crouch_time + crouch_time_length:
		set_collision_height(14, 0)
		set_animation("jump")
		velocity.y = -jump_force
		velocity.x = [jump_x_component, -jump_x_component].pick_random()

	velocity.y += default_gravity * delta
	
	move_and_slide()

func set_animation(anim: String, speed: float = 1.0) -> void:
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)
	$AnimatedSprite2D.speed_scale = speed
	
	for sprite in animated_sprite_ghosts:
		if sprite.animation != anim:
			sprite.play(anim)
		sprite.speed_scale = speed

func set_collision_height(amount: float, offset: float) -> void:
	if $CollisionShape2D.shape.size.y == amount and hitbox_original_pos.y + offset == $CollisionShape2D.position.y:
		return
	$CollisionShape2D.shape.size.y = amount
	$CollisionShape2D.position.y = hitbox_original_pos.y + offset

	for i in range(all_shape_ghosts_original_poses.size()):
		collision_shape_ghosts[i].position.y = all_shape_ghosts_original_poses[i].y + offset
