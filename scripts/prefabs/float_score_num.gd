extends Label

@export var point_value: int = 100
@export var multiplier: int = 1

func _ready():
	if multiplier == 1:
		self.text = str(point_value)
	else:
		self.text = "%dx%d" % [point_value, multiplier]

var cumulative_delta: float = 0
func _process(delta):
	cumulative_delta += delta
	position.y -= 4 * delta
	if cumulative_delta > 1.0:
		self.queue_free()
