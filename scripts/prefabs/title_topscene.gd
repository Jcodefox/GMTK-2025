extends Control

@onready var gameplay_topscene : PackedScene = load("res://scenes/topscenes/gameplay_topscene.tscn");

func _ready() -> void:
	$Buttons/HBoxContainer/High_Score.text = "High Score:\n%012d0" % Globals.high_score;
	$Buttons/HBoxContainer/BestTime.text = "Best Time:\n%02d:%02d" % [int(Globals.longest_time/60),int(Globals.longest_time)%60]
	$Buttons/Start.pressed.connect(_on_start_pressed);
	$Buttons/Credits.pressed.connect(_on_credits_pressed);
	$Credits/Back.pressed.connect(_on_back_pressed);

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(gameplay_topscene);
	Globals.reset_game(false)

func _on_credits_pressed() -> void:
	$Buttons.hide();
	$Credits.show();

func _on_back_pressed() -> void:
	$Buttons.show();
	$Credits.hide();
