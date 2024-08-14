extends CharacterBody2D

@export var speed : float = 300.0
@export var is_right: bool = true
var is_dashing: bool = false
var can_dash: bool = true
var dash_cd: bool = false
var landed: bool = true
var is_attacking: bool = false  # Track if the character is currently attacking

@export var jump_height : float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var double_jump_velocity: float = jump_velocity / 1.25
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0




var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped: bool = false

func jump():
	$AnimatedSprite2D.play("Byrne Jump")
	velocity.y = jump_velocity

func double_jump():
	velocity.y = double_jump_velocity

const ATTACK_ANIMATION_DURATION = 0.3  # Replace with the actual duration of the attack animation

func attack():
	if is_attacking:
		return  # Prevent attacking if already attacking
	
	is_attacking = true
	$AnimatedSprite2D.play("Byrne Sword")  # Play the attack animation
	
	# Wait for the duration of the animation
	await get_tree().create_timer(ATTACK_ANIMATION_DURATION).timeout
	
	# Set is_attacking to false after the timer finishes
	is_attacking = false

	

func _physics_process(delta):
	if velocity.x <= 300 and velocity.x >= -200 and is_on_floor() and not is_attacking:
		is_dashing = false
		$AnimatedSprite2D.play("Byrne Idle")
		
	if is_on_floor():
		landed = true
	
	if landed and not dash_cd:
		can_dash = true    
	
	if is_dashing:
		velocity.y = 975
	else:
		velocity.y += get_gravity() * delta
		
	if is_on_floor():
		has_double_jumped = false
	
	# Handle Jump
	if Input.is_action_just_pressed("Jump") and not is_attacking:
		if is_on_floor():
			jump()
		elif not has_double_jumped:
			double_jump()
			has_double_jumped = true

	# Handle Attack
	if Input.is_action_just_pressed("Attack") and not is_attacking:
		attack()
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("Left", "Right")
	
	if direction < 0:
		is_right = true
	elif direction > 0:
		is_right = false
	
	if direction and not is_dashing and not is_attacking:
		velocity.x = direction * speed
		$AnimatedSprite2D.play("Byrne Run")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if Input.is_action_just_pressed("dash") and can_dash and not dash_cd:
		$AnimatedSprite2D.play("Byrne Dash")
		if is_right:
			velocity.x -= 4500
		else:
			velocity.x += 4500
		is_dashing = true
		landed = false
				
	# Rotate
	if direction == 1:
		$AnimatedSprite2D.flip_h = true
	elif direction == -1:
		$AnimatedSprite2D.flip_h = false
	
	move_and_slide()

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0 else fall_gravity

func _on_dash_timer_timeout():
	dash_cd = false
