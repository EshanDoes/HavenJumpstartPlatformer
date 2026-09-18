extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -450.0
@export var DASH_LENGTH = 100.0
@export var DASH_END_SPEED = 0.1
@export var DASH_ANIM_AMOUNT = 5
@export var DASH_ANIM_STOP = 0.3
@onready var START_POS = Vector2(position.x, position.y)
@onready var DASH_EFFECT = preload("res://scenes/dashEffect.tscn")
@onready var DASH_ANIM_SUBTRACT = 1.0 / DASH_ANIM_AMOUNT
@onready var END_SCREEN = preload("res://scenes/end.tscn").instantiate()

var boostDirection = Vector2(0.0, 0.0)
var boostLeft = 0.0
var canBoost = true
var boostAnimCycle = 1.0
var reachedEnd = false
var loopCount = 0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and loopCount < 200:
		velocity += get_gravity() * delta
		if position.y > 360 and loopCount < 200:
			if !reachedEnd:
				velocity = Vector2(0, 0)
				boostLeft = 0.0
				position = START_POS
				await get_tree().process_frame
			else:
				position.y = -2000
				loopCount += 1
		if loopCount >= 200:
			position.y = -2000
			velocity = Vector2(0, 0)
			add_child(END_SCREEN)
		if position.x > 2286:
			reachedEnd = true
			collision_mask = 0
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	var walking := Input.get_axis("left", "right")
	if direction:
		velocity.x = walking * SPEED
		if boostLeft == 0: boostDirection = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if boostLeft == 0: boostDirection.y = 0
	
	if Input.is_action_just_pressed("dash") and canBoost and !reachedEnd:
		boostLeft = 1.0
		boostAnimCycle = 1.0
		canBoost = false
	
	if boostLeft > 0:
		velocity.x = boostDirection.x * DASH_LENGTH * boostLeft
		velocity.y = boostDirection.y * DASH_LENGTH * boostLeft
		boostLeft -= DASH_END_SPEED * delta
		
		if is_on_wall():
			boostDirection.x = 0
		if is_on_ceiling() and boostDirection.y < 0:
			boostDirection.y = 0
		
		if boostLeft < 0:
			boostLeft = 0.0
		elif boostLeft <= boostAnimCycle and boostAnimCycle >= DASH_ANIM_STOP:
			boostAnimCycle -= DASH_ANIM_SUBTRACT * DASH_ANIM_STOP
			var currentDashEffect = DASH_EFFECT.instantiate()
			currentDashEffect.position = position - Vector2(15, 33)
			get_parent().add_child(currentDashEffect)
	elif is_on_floor():
		canBoost = true
	
	move_and_slide()


func _on_end_body_entered(_body: Node2D) -> void:
	reachedEnd = true
	collision_mask = 0
