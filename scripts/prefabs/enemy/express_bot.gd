extends Enemy

@export var hurt_audio: AudioStream

@export var spikeball_prefab: PackedScene
@export var min_time_between_spikeballs: float = 1.0
@export var max_time_between_spikeballs: float = 5.0
@export var speed: float = 20
@export var hurt_i_frame_time: float = 0.5

var particle_disappear_dist: float = 30
var particle_explosion_force: float = 30

var particle1_ghosts: Array[Node2D] = []
var particle2_ghosts: Array[Node2D] = []
var particle3_ghosts: Array[Node2D] = []

var particle1_ghost_offsets: Array[Vector2] = []
var particle2_ghost_offsets: Array[Vector2] = []
var particle3_ghost_offsets: Array[Vector2] = []

var particle_velocities: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]

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
	
	particle1_ghosts = Globals.make_loop_ghosts_of($ExpressbotFragments1)
	particle2_ghosts = Globals.make_loop_ghosts_of($ExpressbotFragments2)
	particle3_ghosts = Globals.make_loop_ghosts_of($ExpressbotFragments3)
	
	for p in particle1_ghosts:
		particle1_ghost_offsets.push_back(p.position)
	for p in particle2_ghosts:
		particle2_ghost_offsets.push_back(p.position)
	for p in particle3_ghosts:
		particle3_ghost_offsets.push_back(p.position)
	
func _process(delta: float) -> void:
	update_particles(delta)
	if time_alive > time_until_enemy_hurts and (time_since_hurt >= hurt_i_frame_time):
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

func slingballed(_ball: Node2D, ith_enemy: int = 0) -> int:
	if time_since_hurt < hurt_i_frame_time:
		return 0
	health -= 1
	time_since_hurt = 0.0
	activate_particles()
	if health == 0:
		die(ith_enemy)
		return 80
	playsound(hurt_audio)
	return 0

func activate_particles() -> void:
	particle_velocities[0] = Vector2.from_angle(randf_range(0, TAU)) * particle_explosion_force
	particle_velocities[1] = Vector2.from_angle(randf_range(0, TAU)) * particle_explosion_force
	particle_velocities[2] = Vector2.from_angle(randf_range(0, TAU)) * particle_explosion_force
	particle_velocities[0].y -= 200
	particle_velocities[1].y -= 200
	particle_velocities[2].y -= 200
	$ExpressbotFragments1.position = Vector2.ZERO
	$ExpressbotFragments2.position = Vector2.ZERO
	$ExpressbotFragments3.position = Vector2.ZERO
	$ExpressbotFragments1.visible = true
	$ExpressbotFragments2.visible = true
	$ExpressbotFragments3.visible = true

func update_particles(delta: float) -> void:
	if not ($ExpressbotFragments1.visible or $ExpressbotFragments2.visible or $ExpressbotFragments3.visible):
		return
	$ExpressbotFragments1.position += particle_velocities[0] * delta
	$ExpressbotFragments2.position += particle_velocities[1] * delta
	$ExpressbotFragments3.position += particle_velocities[2] * delta
	
	particle_velocities[0].y += default_gravity * delta
	particle_velocities[1].y += default_gravity * delta
	particle_velocities[2].y += default_gravity * delta
	
	if $ExpressbotFragments1.position.length() > particle_disappear_dist:
		$ExpressbotFragments1.visible = false
	if $ExpressbotFragments2.position.length() > particle_disappear_dist:
		$ExpressbotFragments2.visible = false
	if $ExpressbotFragments3.position.length() > particle_disappear_dist:
		$ExpressbotFragments3.visible = false
	
	update_particle_ghosts()

func update_particle_ghosts() -> void:
	for i in range(particle1_ghosts.size()):
		var p = particle1_ghosts[i]
		p.position = $ExpressbotFragments1.position + particle1_ghost_offsets[i]
		p.visible = $ExpressbotFragments1.visible
	for i in range(particle2_ghosts.size()):
		var p = particle2_ghosts[i]
		p.position = $ExpressbotFragments2.position + particle2_ghost_offsets[i]
		p.visible = $ExpressbotFragments2.visible
	for i in range(particle3_ghosts.size()):
		var p = particle3_ghosts[i]
		p.position = $ExpressbotFragments3.position + particle3_ghost_offsets[i]
		p.visible = $ExpressbotFragments3.visible
