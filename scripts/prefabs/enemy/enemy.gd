extends CharacterBody2D

class_name Enemy

var animated_sprite_ghosts: Array[Node2D] = []

@export var default_gravity: float = 625
@export var time_until_enemy_hurts: float = 1.0
var frames_alive: int = 0
var time_alive: float = 0

var dead: bool = false

func _process(_delta: float) -> void:
	if dead:
		return
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
	dead = true
	collision_mask = 0
	collision_layer = 0
	var jump_over_check: Area2D = get_node_or_null("JumpOverCheck")
	if jump_over_check:
		jump_over_check.collision_layer = 0
		jump_over_check.collision_mask = 0
	set_animation("death")
	await get_tree().create_timer(0.5).timeout
	queue_free()
	
func set_animation(anim: String, speed: float = 1.0) -> void:
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)
	$AnimatedSprite2D.speed_scale = speed
	
	for sprite in animated_sprite_ghosts:
		if sprite.animation != anim:
			sprite.play(anim)
		sprite.speed_scale = speed
