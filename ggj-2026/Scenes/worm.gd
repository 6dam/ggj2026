extends CharacterBody2D
var left = true
var SPEED = 200

func _ready():
	pass
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if abs(velocity.x) > 0:
		$AnimatedSprite2D.play()
	
	velocity.x = -SPEED if left else SPEED
	
	move_and_slide()

func _on_timer_timeout() -> void:
	left = !left
	if left: $AnimatedSprite2D.flip_h = false
	else: $AnimatedSprite2D.flip_h = true
