extends Control

func _process(delta: float) -> void:
	$VBoxContainer/Score.text = "Score:\n%012d0" % Globals.score
	$VBoxContainer/Time.text = "Time:\n%02d:%02d" % [int(Globals.time_passed/60),int(Globals.time_passed)%60]


func _on_button_pressed() -> void:
	Globals.reset_game()
