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
