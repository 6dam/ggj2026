extends Sprite2D

func _process(delta: float) -> void:
	self.rotation_degrees = sin(Time.get_ticks_msec() / 500) * 5
