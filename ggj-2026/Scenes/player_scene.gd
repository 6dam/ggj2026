extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var leftMask
var rightMask
var leftMaskButtonTime = 0.0
var rightMaskButtonTime = 0.0
var buttonPressTime = 0.8
@onready var leftMarker = $leftMarker2d
@onready var rightMarker = $rightMarker2d

func _ready() -> void:
	main.player = self

func _physics_process(delta: float) -> void:
	#mask swapping logic - determines if the button has been held long enough and calls the corresponding func
	if Input.is_action_pressed("mask_left"):
		leftMaskButtonTime += delta
	else:
		leftMaskButtonTime = 0
	if leftMaskButtonTime >= buttonPressTime:
		_mask_swap(false)#false for left hand
		leftMaskButtonTime = -buttonPressTime#additional button wait time after swapping
	if Input.is_action_pressed("mask_right"):
		rightMaskButtonTime += delta
	else:
		rightMaskButtonTime = 0
	if rightMaskButtonTime >= buttonPressTime:
		_mask_swap(true)#true for right hand
		rightMaskButtonTime = -buttonPressTime#additional button wait time after swapping
	
	mask_updates()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _mask_use(mask):#func is given the mask name, and does the corresponding action
	match mask.ability:
		"none":
			pass
		"hover":
			pass

func _mask_swap(rightHanded):
	var closestMask = get_closest_mask()
	if rightHanded:
		rightMask = closestMask
		print("Right Swap")
	if !rightHanded:
		leftMask = closestMask
		print("Left Swap")

func get_closest_mask():
	var overlapArray = $maskDetectorArea2D.get_overlapping_bodies()
	var closestMask
	var smallestDistance = 999999
	for i in overlapArray.size():
		if overlapArray[i].is_in_group("mask"):
			if abs(global_position.length() - overlapArray[i].global_position.length()) < smallestDistance:
				smallestDistance = abs(global_position.length() - overlapArray[i].global_position.length())
				closestMask = overlapArray[i]
	return closestMask

func mask_updates():
	if leftMask:
		leftMask.global_position = leftMarker.global_position
