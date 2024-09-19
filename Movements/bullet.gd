extends AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	self.play("bullet")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.is_playing() == false:
		self.play("repeat")


func _on_area_2d_area_entered(area):
	queue_free()
