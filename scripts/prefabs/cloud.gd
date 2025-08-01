extends Sprite2D

func _init():
	position.x = randi_range(-64, 300)
	position.y = randi_range(-32, 224)

func _process(delta):
	position.x -= 0.025
	
	if position.x < -32:
		position.x = randi_range(300, 600)
		position.y = randi_range(-32, 224)
