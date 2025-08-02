extends Control

func _process(_delta: float) -> void:
	$VBoxContainer/Score.text = "Score:\n%012d0" % Globals.score
	$VBoxContainer/HighScore.text = "High Score:\n%012d0" % Globals.high_score
	$VBoxContainer/Time.text = "Time:\n%02d:%02d" % [int(Globals.time_passed/60),int(Globals.time_passed)%60]


func _on_button_pressed() -> void:
	Globals.reset_game()


func _on_button_2_pressed() -> void:
	get_tree().paused = false;
	get_tree().change_scene_to_packed(Globals.title_topscene)
