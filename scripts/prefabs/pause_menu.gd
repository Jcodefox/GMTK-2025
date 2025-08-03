extends Control

@export var click_sound_fx: AudioStream
@export var hover_sound_fx: AudioStream

var held_down = false
var timeout: float = 0.1

func _process(delta: float) -> void:
	timeout -= delta

func _input(event: InputEvent) -> void:
	if Globals.player and Globals.player.dead:
		return
	if (event.is_action_pressed("pause")):
		if (visible):
			hide()
			get_tree().paused = false
		else:
			show()
			get_tree().paused = true

func _on_unpause_pressed() -> void:
	hide()
	get_tree().paused = false
	click_sound()

func _on_title_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(Globals.title_topscene)
	click_sound()

func _on_settings_pressed() -> void:
	$Settings.show()
	$Buttons.hide()
	click_sound()
	
func click_sound() -> void:
	if is_inside_tree():
		$AudioStreamPlayer.stream = click_sound_fx
		$AudioStreamPlayer.play()

func hover_sound() -> void:
	if is_inside_tree():
		$AudioStreamPlayer.stream = hover_sound_fx
		$AudioStreamPlayer.play()
