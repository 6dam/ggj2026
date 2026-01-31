extends Area2D

@export var maskName = "Template"
@export var sprite = preload("res://Art/brainstorm/mask1.png")
var currentGravity = 0
var gravityAcceleration = 600
var maxGravity = 4000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = sprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.player and global.player.leftMask != self and global.player.rightMask != self:
		gravity(delta)
	else:
		currentGravity = 0

func gravity(delta):
	currentGravity += gravityAcceleration*delta
	if currentGravity >= maxGravity:
		currentGravity = clampf(currentGravity,0,maxGravity)
	for i in floor(delta*currentGravity):
		if collision_check() == false:
			global_position.y += 1
		else:
			currentGravity = 0
	
func collision_check():
	var colliding = false
	var overlapArray = get_overlapping_bodies()
	for i in overlapArray:
		if i != global.player:
			colliding = true
	return colliding
	
