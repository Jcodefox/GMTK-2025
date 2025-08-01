extends Label

@export var point_value: int = 100

func _ready():
	self.text = str(point_value)
	print(self.size)

var cumulative_delta: float = 0
func _process(delta):
	cumulative_delta += delta
	position.y -= 4 * delta
	if cumulative_delta > 1.0:
		self.queue_free()
