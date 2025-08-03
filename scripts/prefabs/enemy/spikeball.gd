extends Enemy

@export var spikeball_lifespan: float = 10.0

var collision_shape_ghosts: Array[Node2D] = []
var jump_check_shape_ghosts: Array[Node2D] = []

var all_shape_ghosts_original_poses: PackedVector2Array = []

@onready var hitbox_original_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	jump_check_shape_ghosts = Globals.make_loop_ghosts_of($JumpOverCheck/CollisionShape2D)
	
	hitbox_original_pos = $CollisionShape2D.position
	for shape in collision_shape_ghosts:
		all_shape_ghosts_original_poses.append(shape.position)
		
func _process(_delta: float) -> void:
	if time_alive > time_until_enemy_hurts and not time_alive > spikeball_lifespan - 0.5:
		visible = true
		modulate.a = 1.0
	elif Globals.do_things_flicker:
		visible = frames_alive % 4 < 2
		frames_alive += 1
	else:
		modulate.a = 0.5

func _physics_process(delta: float) -> void:
	if dead:
		return
	super(delta)
	global_position = Globals.apply_loop_teleport(global_position)
	if time_alive > spikeball_lifespan:
		die()

	velocity.y += default_gravity * delta
	velocity.x *= pow(0.0002, delta)
	
	move_and_slide()

func set_collision_height(amount: float, offset: float) -> void:
	if $CollisionShape2D.shape.size.y == amount and hitbox_original_pos.y + offset == $CollisionShape2D.position.y:
		return
	$CollisionShape2D.shape.size.y = amount
	$CollisionShape2D.position.y = hitbox_original_pos.y + offset

	for i in range(all_shape_ghosts_original_poses.size()):
		collision_shape_ghosts[i].position.y = all_shape_ghosts_original_poses[i].y + offset
		
func lassod() -> int:
	queue_free()
	return 1

func slingballed(_ball: Node2D, ith_enemy: int = 0) -> int:
	die(ith_enemy)
	return 1
