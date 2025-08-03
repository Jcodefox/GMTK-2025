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

var time_until_new_out_mode: float = 0.0
var out_mode: int = OUTMODES.PAUSE
enum OUTMODES {
	PAUSE,
	
	MIXED_SPIKROS_MOTHS,
	MOTH_BOMB,
	
	FULL_RANDOM,
}

var spawn_rate_min_wait: float = 1.0
var spawn_rate_max_wait: float = 2.0
var time_to_next_spawn: float = 1.5

func change_out_mode_to(out_mode: int):
	match out_mode:
		OUTMODES.PAUSE:
			time_until_new_out_mode = randf_range(1.0, 5.0)
	pass

func _process(delta: float) -> void:
	time_until_new_out_mode -= delta
	if time_until_new_out_mode <= 0.0:
		if (Globals.time_passed > 0) and (Globals.time_passed < 30):
			match randi_range(0,2):
				0:
					pass
				1:
					pass
				2:
					pass
		else:
			change_out_mode_to(OUTMODES.PAUSE)

func _physics_process(delta: float) -> void:
	time_to_next_spawn -= delta
	
	if time_to_next_spawn <= 0.0:
		var new_enemy: Node2D = enemy_scenes.pick_random().instantiate()
		new_enemy.global_position = global_position 
		var output_direction = (randi_range(0, 1) * 2) - 1 # random +/- 1
		new_enemy.position.x += 200 * output_direction
		enemy_holder_node.add_child(new_enemy)
		time_to_next_spawn = randf_range(1.0, 7.0)
