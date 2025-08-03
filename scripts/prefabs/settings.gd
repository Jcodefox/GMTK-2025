extends Control

@export var other_to_make_visible: Node = null

@onready var parent_control: Control = get_parent()

var timeout: float = 0.4

func _ready() -> void:
	$VBoxContainer/Back.pressed.connect(_back)
	$VBoxContainer/Reset.pressed.connect(_reset)
	
	$VBoxContainer/SFX.toggled.connect(_toggle_sfx)
	$VBoxContainer/Music.toggled.connect(_toggle_music)
	$VBoxContainer/FlickeringDisable.toggled.connect(_toggle_flicker)
	$VBoxContainer/KeybindGrowLasso.toggled.connect(_toggle_lasso_keybind)

func _process(delta: float) -> void:
	timeout -= delta
	timeout = max(timeout, 0.0)
	$VBoxContainer/SFX.button_pressed = Globals.sfx
	$VBoxContainer/Music.button_pressed = Globals.music
	$VBoxContainer/FlickeringDisable.button_pressed = not Globals.do_things_flicker
	$VBoxContainer/KeybindGrowLasso.button_pressed = Globals.lasso_keybind

func _back() -> void:
	self.visible = false
	if other_to_make_visible != null:
		other_to_make_visible.visible = true
	if parent_control:
		parent_control.click_sound()
		
func _reset() -> void:
	Globals.high_score = 0
	Globals.longest_time = 0
	Globals.save_high_score()
	if parent_control:
		parent_control.click_sound()
		
func _toggle_music(val: bool) -> void:
	if parent_control and Globals.music != val and timeout <= 0.0:
		parent_control.click_sound()
	Globals.music = val
	Globals.save_high_score()
	
func _toggle_sfx(val: bool) -> void:
	if parent_control and Globals.sfx != val and timeout <= 0.0:
		parent_control.click_sound()
	Globals.sfx = val
	Globals.save_high_score()
	
func _toggle_flicker(val: bool) -> void:
	if parent_control and Globals.do_things_flicker == val and timeout <= 0.0:
		parent_control.click_sound()
	Globals.do_things_flicker = not val
	Globals.save_high_score()
	
func _toggle_lasso_keybind(val: bool) -> void:
	Globals.lasso_keybind = val
	Globals.save_high_score()
	if parent_control and timeout <= 0.0:
		parent_control.click_sound()

func hover_sound() -> void:
	if parent_control and timeout <= 0.0:
		parent_control.hover_sound()
