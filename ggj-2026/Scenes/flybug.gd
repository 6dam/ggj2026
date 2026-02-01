extends Path2D

@export var speed = 45

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PathFollow2D/Flybug/AnimatedSprite2D.play("bugFly")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PathFollow2D.progress -= delta*speed
