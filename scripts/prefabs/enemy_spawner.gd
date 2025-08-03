extends Node2D

@export var enemy_holder_node: Node2D
@export var enemy_scenes: Array[PackedScene] = []
enum ENEMY {
	SPIKRO = 0,
	MOTHICK = 1,
	SHOCK_WISP = 2,
	SPROING = 3,
	NAMELESS = 4,
	DRONE = 5,
	EXPRESS_BOT = 6,
	SPIKEBALL = 7,
}

var time_until_new_out_mode: float = 2.0
var out_mode: int = OUTMODES.PAUSE
enum OUTMODES {
	PAUSE,
	SPIKROS,
	MIXED_SPIKROS_MOTHS,
	MOTHICKS,
	MOTH_BOMB,
	MIXED_4,
	SHOCK_WISP_BURST,
	MIXED_5,
	MIXED_5_BURST,
	MIXED_6,
	
	SPIKEBALL_COUGH,
	
	FULL_RANDOM,
}

var spawn_rate_min_wait: float = 1.0
var spawn_rate_max_wait: float = 2.0
var time_to_next_spawn: float = 0.0

func spawn_enemy(enemy_type: int, direction: int = 0, velocity: Vector2 = Vector2(0,0)) -> void:
	if direction == 0:
		direction = [-1, 1].pick_random()
	var new_enemy: Node2D = enemy_scenes[enemy_type].instantiate()
	new_enemy.global_position = global_position
	new_enemy.position.x += 20 * direction
	new_enemy.z_index = 32
	enemy_holder_node.add_child(new_enemy)
	new_enemy.velocity = velocity * direction

func change_out_mode_to(out_mode_input: int) -> void:
	out_mode = out_mode_input
	time_to_next_spawn = 0
	time_until_new_out_mode = randf_range(1.0, 4.0)
	spawn_rate_min_wait = 0.5; spawn_rate_max_wait = 1.0
	match out_mode:
		OUTMODES.PAUSE:
			time_until_new_out_mode = randf_range(1.0, 4.0)
			spawn_rate_min_wait = 0.0; spawn_rate_max_wait = 1.0
		OUTMODES.SPIKROS, OUTMODES.MIXED_SPIKROS_MOTHS, OUTMODES.MOTHICKS:
			time_until_new_out_mode = randf_range(4.0, 6.0)
			spawn_rate_min_wait = 1.5; spawn_rate_max_wait = 2.5
		OUTMODES.MOTH_BOMB:
			time_until_new_out_mode = randf_range(0.5, 1.0)
			spawn_rate_min_wait = 0.1; spawn_rate_max_wait = 0.2
		OUTMODES.MIXED_4:
			time_until_new_out_mode = randf_range(4.0, 6.0)
			spawn_rate_min_wait = 1.0; spawn_rate_max_wait = 2.0
		OUTMODES.SHOCK_WISP_BURST, OUTMODES.MIXED_5_BURST:
			time_until_new_out_mode = randf_range(0.25, 0.5)
			spawn_rate_min_wait = 0.1; spawn_rate_max_wait = 0.2
		OUTMODES.SPIKEBALL_COUGH:
			time_until_new_out_mode = randf_range(0.2, 0.35)
			spawn_rate_min_wait = 0.05; spawn_rate_max_wait = 0.15
		OUTMODES.MIXED_5:
			time_until_new_out_mode = randf_range(4.0, 6.0)
			spawn_rate_min_wait = 0.75; spawn_rate_max_wait = 1.25
		OUTMODES.MIXED_6:
			time_until_new_out_mode = randf_range(4.0, 6.0)
			spawn_rate_min_wait = 0.6; spawn_rate_max_wait = 1.0


func _process(delta: float) -> void:
	time_until_new_out_mode -= delta
	time_to_next_spawn -= delta
	
	
	
	if time_until_new_out_mode <= 0.0:
		time_to_next_spawn = 0
		if Globals.time_passed < 0:
			change_out_mode_to(OUTMODES.PAUSE)
		elif Globals.time_passed < 20:
			match randi_range(0,5):
				0:
					change_out_mode_to(OUTMODES.PAUSE)
				2:
					change_out_mode_to(OUTMODES.SPIKROS)
				3, 4:
					change_out_mode_to(OUTMODES.MIXED_SPIKROS_MOTHS)
				5:
					change_out_mode_to(OUTMODES.MOTHICKS)
				6:
					change_out_mode_to(OUTMODES.MOTH_BOMB)
		elif Globals.time_passed < 50:
			match randi_range(0,9):
				0, 1:
					change_out_mode_to(OUTMODES.PAUSE)
				2, 3:
					change_out_mode_to(OUTMODES.MOTH_BOMB)
				4, 5, 6, 7, 8:
					change_out_mode_to(OUTMODES.MIXED_4)
				9:
					change_out_mode_to(OUTMODES.SHOCK_WISP_BURST)
		elif Globals.time_passed < 80:
			match randi_range(0,6):
				0:
					change_out_mode_to(OUTMODES.PAUSE)
				1:
					change_out_mode_to(OUTMODES.MOTH_BOMB)
				2:
					change_out_mode_to(OUTMODES.MIXED_4)
				3:
					change_out_mode_to(OUTMODES.SHOCK_WISP_BURST)
				4, 5, 6:
					change_out_mode_to(OUTMODES.MIXED_5)
		elif Globals.time_passed < 120:
			match randi_range(0,6):
				0:
					change_out_mode_to(OUTMODES.MIXED_SPIKROS_MOTHS)
				1:
					change_out_mode_to(OUTMODES.MIXED_5)
				3:
					change_out_mode_to(OUTMODES.MIXED_5_BURST)
		elif Globals.time_passed < 160:
			match randi_range(0,12):
				0, 1:
					change_out_mode_to(OUTMODES.MIXED_SPIKROS_MOTHS)
				2, 3:
					change_out_mode_to(OUTMODES.MIXED_5)
				4, 5:
					change_out_mode_to(OUTMODES.MIXED_5_BURST)
				6, 7, 8, 9, 10, 11:
					change_out_mode_to(OUTMODES.MIXED_6)
				12:
					change_out_mode_to(OUTMODES.SPIKEBALL_COUGH)
		else:
			change_out_mode_to(OUTMODES.FULL_RANDOM)
		
		#if not out_mode == OUTMODES.SHOCK_WISP_BURST:
			#change_out_mode_to(OUTMODES.SHOCK_WISP_BURST)
		#else:
			#change_out_mode_to(OUTMODES.PAUSE)
	
	if time_to_next_spawn < 0:
		time_to_next_spawn = randf_range(spawn_rate_min_wait, spawn_rate_max_wait)
		match out_mode:
			OUTMODES.PAUSE:
				pass
			OUTMODES.SPIKROS:
				spawn_enemy(ENEMY.SPIKRO)
			OUTMODES.MIXED_SPIKROS_MOTHS:
				match randi_range(0, 1):
					0:
						spawn_enemy(ENEMY.SPIKRO)
					1:
						spawn_enemy(ENEMY.MOTHICK)
			OUTMODES.MOTH_BOMB:
				spawn_enemy(ENEMY.MOTHICK)
			OUTMODES.MIXED_4:
				match randi_range(0, 7):
					0, 1:
						spawn_enemy(ENEMY.SPIKRO)
					2, 3:
						spawn_enemy(ENEMY.MOTHICK)
					4:
						spawn_enemy(ENEMY.SHOCK_WISP)
					5, 6:
						spawn_enemy(ENEMY.SPROING)
			OUTMODES.SHOCK_WISP_BURST:
				spawn_enemy(ENEMY.SHOCK_WISP)
			OUTMODES.MIXED_5, OUTMODES.MIXED_5_BURST:
				match randi_range(0, 4):
					0:
						spawn_enemy(ENEMY.SPIKRO)
					1:
						spawn_enemy(ENEMY.MOTHICK)
					2:
						spawn_enemy(ENEMY.SHOCK_WISP)
					3:
						spawn_enemy(ENEMY.SPROING)
					4:
						spawn_enemy(ENEMY.NAMELESS)
			OUTMODES.MIXED_6:
				match randi_range(0, 5):
					0:
						spawn_enemy(ENEMY.SPIKRO)
					1:
						spawn_enemy(ENEMY.MOTHICK)
					2:
						spawn_enemy(ENEMY.SHOCK_WISP)
					3:
						spawn_enemy(ENEMY.SPROING)
					4:
						spawn_enemy(ENEMY.NAMELESS)
					5:
						spawn_enemy(ENEMY.DRONE)
			OUTMODES.SPIKEBALL_COUGH:
				spawn_enemy(ENEMY.SPIKEBALL, 0, Vector2(randf_range(0, 200), randf_range(0, -45)))
			OUTMODES.FULL_RANDOM:
				match randi_range(0, 6):
					0:
						spawn_enemy(ENEMY.SPIKRO)
					1:
						spawn_enemy(ENEMY.MOTHICK)
					2:
						spawn_enemy(ENEMY.SHOCK_WISP)
					3:
						spawn_enemy(ENEMY.SPROING)
					4:
						spawn_enemy(ENEMY.NAMELESS)
					5:
						spawn_enemy(ENEMY.DRONE)
					6:
						spawn_enemy(ENEMY.EXPRESS_BOT)
