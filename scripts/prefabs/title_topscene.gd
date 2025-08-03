extends Control

@export var click_sound_fx: AudioStream
@export var hover_sound_fx: AudioStream

@onready var gameplay_topscene : PackedScene = load("res://scenes/topscenes/gameplay_topscene.tscn");

var timeout: float = 0.1

func _ready() -> void:
	$Buttons/Start.pressed.connect(_on_start_pressed);
	$Buttons/Settings.pressed.connect(_on_settings_pressed);
	$Buttons/Credits.pressed.connect(_on_credits_pressed);
	$Buttons/Quit.pressed.connect(_on_quit_pressed);
	$Credits/Back.pressed.connect(_on_back_pressed);

func _process(delta: float) -> void:
	timeout -= delta
	$Buttons/HBoxContainer/High_Score.text = "High Score:\n%012d0" % Globals.high_score;
	$Buttons/HBoxContainer/BestTime.text = "Best Time:\n%02d:%02d" % [int(Globals.longest_time/60),int(Globals.longest_time)%60]

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(gameplay_topscene);
	Globals.reset_game(false)
	click_sound()

func _on_settings_pressed() -> void:
	$Buttons.hide()
	$Settings.show()
	click_sound()
	
func _on_credits_pressed() -> void:
	$Buttons.hide()
	$Credits.show()
	click_sound()

func _on_back_pressed() -> void:
	$Buttons.show()
	$Credits.hide()
	click_sound()

func _on_quit_pressed() -> void:
	get_tree().quit()
	click_sound()

func click_sound() -> void:
	if not is_inside_tree():
		return
	if timeout <= 0.0:
		$AudioStreamPlayer.stream = click_sound_fx
		$AudioStreamPlayer.play()

func hover_sound() -> void:
	if not is_inside_tree():
		return
	if timeout <= 0.0:
		$AudioStreamPlayer.stream = hover_sound_fx
		$AudioStreamPlayer.play()
