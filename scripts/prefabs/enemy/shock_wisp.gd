extends CharacterBody2D

@export var time_until_enemy_hurts: float = 1.0

@export var default_gravity: float = 625
@export var move_speed: float = 50

var move_direction: int = 0

var time_alive: float = 0

@onready var corners: Array[Area2D] = [$BottomRight, $BottomLeft, $TopLeft, $TopRight]

var animated_sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var jump_check_shape_ghosts: Array[Node2D] = []

var direction: int = 1

func _ready() -> void:
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	jump_check_shape_ghosts = Globals.make_loop_ghosts_of($JumpOverCheck/CollisionShape2D)
	direction = [-1, 1].pick_random()
	for i in range(corners.size()):
		if direction == -1:
			corners[i].position += [Vector2(-2, 0), Vector2(0, -2), Vector2(2, 0), Vector2(0, 2)][i]
		for child in corners[i].get_children():
			Globals.make_loop_ghosts_of(child)

func _physics_process(delta: float) -> void:
	time_alive += delta
	update_i_frames()
	global_position = Globals.apply_loop_teleport(global_position)

	var angle: float = float(move_direction)/4 * TAU
	
	var next_corner: int = correct_direction(move_direction + direction)

	var next_corner_miss: bool = corners[next_corner].get_overlapping_bodies().size() == 0
	var corner_miss: bool = corners[move_direction].get_overlapping_bodies().size() == 0
	if corner_miss and not next_corner_miss:
		move_direction = correct_direction(move_direction + direction)
	
	if corners[correct_direction(move_direction + 3 * direction)].get_overlapping_bodies().size() != 0:
		move_direction = correct_direction(move_direction + 3 * direction)
		

	velocity = Vector2(cos(angle), sin(angle)) * move_speed * direction
	move_and_slide()

func update_i_frames() -> void:
	if time_alive >= time_until_enemy_hurts:
		visible = true
		return
	visible = int(time_alive * 8) % 2 < 1

func correct_direction(dir: int) -> int:
	return posmod(dir, 4)
