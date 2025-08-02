extends Enemy

@export var spikeball_prefab: PackedScene
@export var min_time_between_spikeballs: float = 1.0
@export var max_time_between_spikeballs: float = 5.0
@export var speed: float = 20
@export var hurt_i_frame_time: float = 0.5

var animated_sprite_ghosts: Array[Node2D] = []
var collision_shape_ghosts: Array[Node2D] = []
var jump_check_shape_ghosts: Array[Node2D] = []

var health: int = 3
@onready var time_since_hurt: float = hurt_i_frame_time

var time_until_next_spikeball: float = 0.0

func _ready() -> void:
	time_until_next_spikeball = randf_range(min_time_between_spikeballs, max_time_between_spikeballs)
	animated_sprite_ghosts = Globals.make_loop_ghosts_of($AnimatedSprite2D)
	collision_shape_ghosts = Globals.make_loop_ghosts_of($CollisionShape2D)
	jump_check_shape_ghosts = Globals.make_loop_ghosts_of($JumpOverCheck/CollisionShape2D)
	
func _process(_delta: float) -> void:
	if time_alive > time_until_enemy_hurts and (time_since_hurt >= hurt_i_frame_time):
		visible = true
	elif Globals.do_things_flicker:
		visible = frames_alive % 4 < 2
		frames_alive += 1

func _physics_process(delta: float) -> void:
	super(delta)
	global_position = Globals.apply_loop_teleport(global_position)
	
	time_since_hurt += delta
	time_until_next_spikeball -= delta
	if time_until_next_spikeball <= 0.0:
		time_until_next_spikeball = randf_range(min_time_between_spikeballs, max_time_between_spikeballs)
		var new_spikeball: Node2D = spikeball_prefab.instantiate()
		new_spikeball.global_position = Globals.convert_to_visible_pos(global_position)
		get_parent().add_child(new_spikeball)

	var desired_direction: Vector2 = Vector2.ZERO
	if Globals.player != null and Globals.player.is_inside_tree():
		desired_direction = Globals.convert_to_visible_pos(global_position).direction_to(Globals.convert_to_visible_pos(Globals.player.global_position))
	set_animation(["c", "b", "a"][health - 1])
	
	velocity += desired_direction
	velocity = velocity.normalized() * speed
	
	move_and_slide()

func set_animation(anim: String) -> void:
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)
	
	for sprite in animated_sprite_ghosts:
		if sprite.animation != anim:
			sprite.play(anim)

func slingballed(ball: Node2D) -> void:
	if time_since_hurt < hurt_i_frame_time:
		return
	health -= 1
	time_since_hurt = 0.0
	if health == 0:
		die()
