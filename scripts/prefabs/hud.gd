extends Control

func _process(_delta: float) -> void:
	$Lives.text = "\n         x%d" % Globals.lives
	$Score.text = "SCORE\n%011d0" % Globals.score
	$Next.text = "NEXT\n%011d0" % Globals.next
	$Time.text = "TIME\n%02d:%02d" % [int(Globals.time_passed/60),int(Globals.time_passed)%60]
