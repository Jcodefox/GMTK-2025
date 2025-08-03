extends Control

@export var other_to_make_visible: Node = null

func _ready() -> void:
	$VBoxContainer/Back.pressed.connect(_back)
	
	$VBoxContainer/SFX.toggled.connect(_toggle_sfx)
	$VBoxContainer/Music.toggled.connect(_toggle_music)
	$VBoxContainer/FlickeringDisable.toggled.connect(_toggle_flicker)
	$VBoxContainer/KeybindGrowLasso.toggled.connect(_toggle_lasso_keybind)

func _process(_delta: float) -> void:
	$VBoxContainer/SFX.button_pressed = Globals.sfx
	$VBoxContainer/Music.button_pressed = Globals.music
	$VBoxContainer/FlickeringDisable.button_pressed = not Globals.do_things_flicker
	$VBoxContainer/KeybindGrowLasso.button_pressed = Globals.lasso_keybind

func _back() -> void:
	self.visible = false
	if other_to_make_visible != null:
		other_to_make_visible.visible = true
		
func _toggle_music(val: bool) -> void:
	Globals.music = val
	
func _toggle_sfx(val: bool) -> void:
	Globals.sfx = val
	
func _toggle_flicker(val: bool) -> void:
	Globals.do_things_flicker = not val
	
func _toggle_lasso_keybind(val: bool) -> void:
	Globals.lasso_keybind = val
