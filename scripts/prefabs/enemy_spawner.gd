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
}

var time_until_new_out_mode: float = 2.0
var out_mode: int = OUTMODES.PAUSE
enum OUTMODES {
	PAUSE,
	
	SPIKROS,
	MIXED_SPIKROS_MOTHS,
	MOTHICKS,
	MOTH_BOMB,
	
	FULL_RANDOM,
}

var spawn_rate_min_wait: float = 1.0
var spawn_rate_max_wait: float = 2.0
var time_to_next_spawn: float = 0.0

func spawn_enemy(enemy_type: int, direction: int = 0) -> void:
	var new_enemy: Node2D = enemy_scenes[enemy_type].instantiate()
	new_enemy.global_position = global_position
	new_enemy.position.x += (20 * [-1, 1].pick_random()) if direction == 0 else (20 * direction)
	new_enemy.z_index = 32
	enemy_holder_node.add_child(new_enemy)

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
			time_until_new_out_mode = randf_range(0.5, 0.75)
			spawn_rate_min_wait = 0.1; spawn_rate_max_wait = 0.2

func _process(delta: float) -> void:
	time_until_new_out_mode -= delta
	time_to_next_spawn -= delta
	
	if time_until_new_out_mode <= 0.0:
		time_to_next_spawn = 0
		if (Globals.time_passed > 0) and (Globals.time_passed < 999):
			match randi_range(0,5):
				0, 1:
					change_out_mode_to(OUTMODES.PAUSE)
				2:
					change_out_mode_to(OUTMODES.SPIKROS)
				3, 4:
					change_out_mode_to(OUTMODES.MIXED_SPIKROS_MOTHS)
				5:
					change_out_mode_to(OUTMODES.MOTHICKS)
				6:
					change_out_mode_to(OUTMODES.MOTH_BOMB)
		else:
			change_out_mode_to(OUTMODES.FULL_RANDOM)
	
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
