extends Control

var held_down = false

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pause")):
		if (visible):
			hide();
			get_tree().paused = false;
		else:
			show();
			get_tree().paused = true;

func _on_unpause_pressed() -> void:
	hide();
	get_tree().paused = false;

func _on_title_pressed() -> void:
	get_tree().paused = false;
	get_tree().change_scene_to_packed(Globals.title_topscene);

func _on_settings_pressed() -> void:
	$Settings.show()
	$Buttons.hide()
