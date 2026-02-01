extends CharacterBody2D

@onready var flightTimer = $flightTimer
var floorY

func _ready():
	floorY = self.global_position.y-60
	velocity += Vector2(0,-300)
	$AnimatedSprite2D.play("flap")
	#print(startingY)

func _physics_process(delta: float) -> void:
	#print(self.global_position.y)
	# Add the gravity.
	if self.global_position.y > floorY:
		velocity += Vector2(0,-300)*delta
		#flightTimer.start(1)
	else:
		velocity += get_gravity() * 0.5 * delta
		
	move_and_slide()
