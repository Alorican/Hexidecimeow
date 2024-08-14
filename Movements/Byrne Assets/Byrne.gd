extends CharacterBody2D


@export var speed : float = 300.0
@export var is_right: bool = true
var is_dashing: bool = false
var can_dash: bool = true
var dash_cd: bool = false
var landed: bool = true

@export var jump_height : float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var double_jump_velocity: float = jump_velocity / 1.25
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped : bool = false

func jump():
	$AnimatedSprite2D.play("Byrne Jump")
	velocity.y = jump_velocity

func double_jump():
	velocity.y = double_jump_velocity

func _physics_process(delta):
	#print(position.y)
	if velocity.x <= 300 && velocity.x >= -200 && is_on_floor():
		is_dashing = false;
		$AnimatedSprite2D.play("Byrne Idle")
		
	if is_on_floor():
		landed = true
	
	if landed && !dash_cd:
		can_dash = true	
	
	if is_dashing:
		velocity.y = 975
	else:
		velocity.y += get_gravity() * delta
	#print(get_gravity())
		
	# Add the gravity.
	if is_on_floor():
		has_double_jumped = false;
	# Handle jump.
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor():
			#Normal jump from floor
			jump();
		elif not has_double_jumped:
			# Double jump if it hasn't been used yet
			double_jump()
			# Can also try using
			# velocity.y += double_jump_velocity
			has_double_jumped = true;
			
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Left", "Right")
	
	if direction < 0:
		is_right = true
	elif direction > 0:
		is_right = false
	if direction && !is_dashing:
		velocity.x = direction * speed
		$AnimatedSprite2D.play("Byrne Run")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if Input.is_action_just_pressed("dash") && can_dash && !dash_cd:
		$AnimatedSprite2D.play("Byrne Dash")
		if is_right:
			velocity.x = velocity.x -4500
		elif !is_right:
			velocity.x = velocity.x +4500
		is_dashing = true
		#can_dash = false
		#dash_cd = true
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


