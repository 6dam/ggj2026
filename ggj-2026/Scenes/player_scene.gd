extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const POUND_VELOCITY = 1000

var swordScene = preload("res://Scenes/sword.tscn")

var leftMask
var rightMask
var hovering = false
var hoverUsable = false
var dashVector = 0

@onready var defaultMarkerPosition = $armPivotMarker.position
var leftMarkerPosition = Vector2(18,-38)
var rightMarkerPosition = Vector2(-18,-38)
var leftMarkerTilt = 12.0
var rightMarkerTilt = -12.0
var maskMode = 0

@onready var leftMarker = $armPivotMarker/leftMarker2d
@onready var rightMarker = $armPivotMarker/rightMarker2d
@onready var animatedSprite = $AnimatedSprite2D
@onready var sludgeTimer = $sludgeTimer


func _ready() -> void:
	global.player = self
	global.poundReady = true

func _physics_process(delta: float) -> void:
	maskModeUpdate()
	# Add the gravity.
	if not is_on_floor() and hovering == false:
		velocity += get_gravity() * delta
	
	if is_on_floor():
		hoverUsable = true
		global.poundReady = false
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		hovering = false
		if $jumpSound.playing == false:
			$jumpSound.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if $footstepSound.playing == false:
			if is_on_floor():
				$footstepSound.play()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/18)
	
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
	
	#velocity.x += dashVector
	position.x += dashVector
	move_and_slide()
	mask_updates()
	dashVector = move_toward(dashVector,0,400*delta)
	if is_on_wall():
		dashVector = 0
		
	#mask swapping inputs
	if Input.is_action_just_pressed("swap_left"):
		_mask_swap(false)#false for left hand
	if Input.is_action_just_pressed("swap_right"):
		_mask_swap(true)#true for right hand
		
	#Mask action inputs
	if Input.is_action_pressed("mask_left"):
		_mask_use(leftMask, direction)
		maskMode = -1
		$maskUseTimer.start()
	if Input.is_action_pressed("mask_right"):
		_mask_use(rightMask, direction)
		maskMode = 1
		$maskUseTimer.start()

func _mask_use(mask, direction):#func is given the mask name, and does the corresponding action
	if mask:
		match mask.maskName:
			"sword":
				if $swordTimer.is_stopped():
					var swordInstance = swordScene.instantiate()
					add_child(swordInstance)
					$swordTimer.start(.8)
					if animatedSprite.flip_h == true:
						swordInstance.scale.x = -1
					if $swordSound.playing == false:
						$swordSound.play()
			"dash":
				if $dashTimer.is_stopped():
					dashVector = 50 * direction
					$dashTimer.start()
					if $dashSound.playing == false:
						$dashSound.play()
			"hover":
				if hoverUsable == true:
					hoverUsable = false
					hovering = true
					velocity.y = 0
					$hoverTimer.start()
					if $hoverSound.playing == false:
						$hoverSound.play()
			"highjump":
				if is_on_floor():
					velocity.y = -600
					hovering = false
					if $highjumpSound.playing == false:
						$highjumpSound.play()
			"none":
				pass
			"Template":
				velocity.y = JUMP_VELOCITY
			"sludge":
				shootSludge(mask)
			"groundpound":
				if !is_on_floor():
					velocity.y = POUND_VELOCITY
					global.poundReady = true
					if $poundSound.playing == false:
						$poundSound.play()

func _mask_swap(rightHanded):
	var closestMask = get_closest_mask()
	if rightHanded:
		rightMask = closestMask
		print("Right Swap")
	if !rightHanded:
		leftMask = closestMask
		print("Left Swap")
	if $beepSound.playing == false:
		$beepSound.play()

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
	global.main.deathSound()
	global.main.load_level(global.currentLevel)


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
		$sludgeSound.play()
	


func _on_ground_pound_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and global.poundReady:
		area.owner.queue_free()


func _on_mask_use_timer_timeout() -> void:
	maskMode = 0

func maskModeUpdate():
	var pivot = $armPivotMarker
	var armSpeed = 0.3
	if maskMode == 0:
		pivot.position = lerp(pivot.position, defaultMarkerPosition, armSpeed)
		pivot.rotation_degrees = lerp(pivot.rotation_degrees, 0.0, armSpeed)
		pivot.scale = lerp(pivot.scale, Vector2(1,1), armSpeed)
		$armPivotMarker/leftMarker2d/Sprite2D.z_index = 0
		$armPivotMarker/rightMarker2d/Sprite2D.z_index = 0
	if maskMode == 1:
		pivot.position = lerp(pivot.position, rightMarkerPosition, armSpeed)
		pivot.rotation_degrees = lerp(pivot.rotation_degrees, rightMarkerTilt, armSpeed)
		pivot.scale = lerp(pivot.scale, Vector2(0.6,0.6), armSpeed)
		$armPivotMarker/leftMarker2d/Sprite2D.z_index = 1
		$armPivotMarker/rightMarker2d/Sprite2D.z_index = 1
	if maskMode == -1:
		pivot.position = lerp(pivot.position, leftMarkerPosition, armSpeed)
		pivot.rotation_degrees = lerp(pivot.rotation_degrees, leftMarkerTilt, armSpeed)
		pivot.scale = lerp(pivot.scale, Vector2(0.6,0.6), armSpeed)
		$armPivotMarker/leftMarker2d/Sprite2D.z_index = 1
		$armPivotMarker/rightMarker2d/Sprite2D.z_index = 1
