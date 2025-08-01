extends Node2D

@export var enemy_holder_node: Node2D
@export var enemy_scenes: Array[PackedScene] = []
var time_to_next: float = 2.0

func _ready() -> void:
	time_to_next = randf_range(1.0, 2.0)

func _physics_process(delta: float) -> void:
	time_to_next -= delta

	if time_to_next <= 0.0:
		var new_enemy: Node2D = enemy_scenes.pick_random().instantiate()
		new_enemy.global_position = global_position
		enemy_holder_node.add_child(new_enemy)
		time_to_next = randf_range(1.0, 7.0)
