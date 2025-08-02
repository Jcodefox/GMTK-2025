extends Enemy

@export var speed: float = 25

var collision_shape_ghosts: Array[Node2D] = []
var jump_check_shape_ghosts: Array[Node2D] = []

func _ready() -> void:
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	jump_check_shape_ghosts = Globals.make_loop_ghosts_of($JumpOverCheck/CollisionShape2D)

func _physics_process(delta: float) -> void:
	if dead:
		return
	super(delta)
	global_position = Globals.apply_loop_teleport(global_position)

	var desired_direction: Vector2 = Vector2.ZERO
	if Globals.player != null and Globals.player.is_inside_tree():
		desired_direction = Globals.convert_to_visible_pos(global_position).direction_to(Globals.convert_to_visible_pos(Globals.player.global_position))
	
	velocity += desired_direction * 0.75
	velocity = velocity.normalized() * speed
	
	move_and_slide()
			
func slingballed(_ball: Node2D) -> int:
	die()
	return 30
