extends Control

func _process(delta: float) -> void:
	$HBoxContainer/Lives.text = "Lives:\nCOWBOY x %d" % Globals.lives
	$HBoxContainer/Score.text = "Score:\n%012d" % Globals.score
	$HBoxContainer/Time.text = "Time:\n%02d:%02d" % [int(Globals.time_passed/60),int(Globals.time_passed)%60]
