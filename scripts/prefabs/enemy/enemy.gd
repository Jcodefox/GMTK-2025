extends CharacterBody2D

class_name Enemy

@export var default_gravity: float = 625
@export var time_until_enemy_hurts: float = 1.0
var frames_alive: int = 0
var time_alive: float = 0

func _process(_delta: float) -> void:
	if time_alive > time_until_enemy_hurts:
		visible = true
	elif Globals.do_things_flicker:
		visible = frames_alive % 4 < 2
		frames_alive += 1

func _physics_process(delta: float) -> void:
	time_alive += delta
	collision_layer = 4 if time_alive > time_until_enemy_hurts else 0

func lassod() -> void:
	queue_free()

func slingballed(_ball: Node2D) -> int:
	die()
	return 10

func die() -> void:
	queue_free()
