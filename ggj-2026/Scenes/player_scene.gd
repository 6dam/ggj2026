extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var leftMask
var rightMask
var hovering = false
var hoverUsable = false
var dashVector = 0
@onready var leftMarker = $leftMarker2d
@onready var rightMarker = $rightMarker2d
@onready var animatedSprite = $AnimatedSprite2D
@onready var sludgeTimer = $sludgeTimer

func _ready() -> void:
	pass
	global.player = self

func _physics_process(delta: float) -> void:
	#mask swapping inputs
	if Input.is_action_just_pressed("swap_left"):
		_mask_swap(false)#false for left hand
	if Input.is_action_just_pressed("swap_right"):
		_mask_swap(true)#true for right hand
		
	#Mask action inputs
	if Input.is_action_pressed("mask_left"):
		_mask_use(leftMask)
	if Input.is_action_pressed("mask_right"):
		_mask_use(rightMask)
	
	# Add the gravity.
	if not is_on_floor() and hovering == false:
		velocity += get_gravity() * delta
	
	if is_on_floor():
		hoverUsable = true
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		hovering = false

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.x += dashVector
	dashVector = dashVector*0.8*delta
	
	if abs(velocity.y)>0:
		animatedSprite.play("jump")
	elif abs(velocity.x) > 0:
		animatedSprite.play("run")
	else:
		animatedSprite.play("idle")
		
	if velocity.x < 0:
		animatedSprite.flip_h = true
	if velocity.x > 0:
		animatedSprite.flip_h = false
	
	move_and_slide()
	mask_updates()

func _mask_use(mask):#func is given the mask name, and does the corresponding action
	if mask:
		match mask.maskName:
			"dash":
				if $dashTimer.is_stopped():
					dashVector = 800
				$dashTimer.start()
			"hover":
				if hoverUsable == true:
					hoverUsable = false
					hovering = true
					velocity.y = 0
					$hoverTimer.start()
			"highjump":
				if is_on_floor():
					velocity.y = -600
					hovering = false
			"none":
				pass
			"hover":
				pass
			"Template":
				velocity.y = JUMP_VELOCITY
			"sludge":
				shootSludge(mask)

func _mask_swap(rightHanded):
	var closestMask = get_closest_mask()
	if rightHanded:
		rightMask = closestMask
		print("Right Swap")
	if !rightHanded:
		leftMask = closestMask
		print("Left Swap")

func get_closest_mask():
	var overlapArray = $maskDetectorArea2D.get_overlapping_areas()
	var closestMask
	var smallestDistance = 999999
	for i in overlapArray.size():
		if overlapArray[i] != leftMask && overlapArray[i] != rightMask:
			if overlapArray[i].is_in_group("mask"):
				if abs(global_position.length() - overlapArray[i].global_position.length()) < smallestDistance:
					smallestDistance = abs(global_position.length() - overlapArray[i].global_position.length())
					closestMask = overlapArray[i]
	return closestMask

func mask_updates():
	if leftMask:
		leftMask.global_position = leftMarker.global_position
	if rightMask:
		rightMask.global_position = rightMarker.global_position

func die():
	global.main.load_level(global.main.level2)


func _on_hitbox_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		die()


func _on_hitbox_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		die()


func _on_hover_timer_timeout() -> void:
	hovering = false
	
func shootSludge(mask):
	if sludgeTimer.is_stopped():
		var sludgeInst = global.sludge_ball.instantiate()
		get_tree().current_scene.add_child(sludgeInst)
		sludgeInst.global_position = mask.global_position
		if animatedSprite.flip_h:
			sludgeInst.linear_velocity = Vector2(-500,-300)
		else:
			sludgeInst.linear_velocity = Vector2(500,-300)
		sludgeTimer.start(1)
	
