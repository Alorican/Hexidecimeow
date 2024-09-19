extends CharacterBody2D

@onready var debug = owner.find_child("debug")
@onready var player = owner.find_child("Byrne")
@onready var scene = owner
@onready var healthbar = $CanvasLayer/Healthbar
@onready var canvas = $CanvasLayer
@onready var hitbox = $Area2D
@onready var body = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animated_shockwave = $shockwave
@export var min_attack : int = 6
@export var max_attack : int = 10

var rng = RandomNumberGenerator.new()
var can_attack : bool = true
var landed : bool = true
var attack = 0
var cain_second_attack : bool = false
var shockwave = preload("res://Shockwave/shockwave.tscn")
var bullet = preload("res://bullet.tscn")
var shockwavePos = 2000.0
var shockwaveNeg = -2000.0
var can_shockwave : bool = true
var count = 1
var is_cooldown : bool = false
var boss_has_exit : bool = false
var second_phase : bool = false
var num_of_attacks : int = 0

@onready var jump_height : float = 1600.00
@onready var jump_time_to_peak: float = 0.6
@onready var jump_time_to_descent: float = 0.6

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var double_jump_velocity: float = jump_velocity / 1.25
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var health = 55

func _ready():
	healthbar.init_health(health)
	canvas.visible = false

func _physics_process(delta):
	if attack < 4:
		if is_cooldown:
			if velocity.y > 3000:
				is_cooldown = false
				if player.position.x <= 4640:
					position.x = 4640
				elif player.position.x >= 7740:
					position.x = 7740
				else:
					position.x = player.position.x
		if !cain_second_attack:
			velocity.y += fall_gravity * delta
		if position.x <= 4640 || position.x >= 7740:
			velocity.x = 0
		if is_on_floor() && !landed:
			velocity.x = 0
			landed = true
		match attack:
			1:
				if landed:
					#animated_sprite_2d.play("idle_Abel")
					while_Abel()
			2:
				if velocity.x == 0 and !boss_has_exit:
					animated_sprite_2d.play("idle_Seth")
			3:
				while_Cain()
				if landed and !boss_has_exit:
					animated_sprite_2d.play("idle_Cain")
		if can_attack:	
			if landed:
				attack += 1
				choose_attack()
				can_attack = false
		if scene.bossBattle && health > 0:
			canvas.visible = true
		else:
			canvas.visible = false
				#else:
				#velocity.y += fall_gravity * delta

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		
	else:
		if is_cooldown:
			velocity.y += fall_gravity * delta
			if velocity.y > 0:
				is_cooldown = false
				position.x = 7780
				animated_sprite_2d.play("entrance_Stacked")
				velocity.y = 0
				hitbox.scale.y = 3
				body.scale.y = body.scale.y * 3
		if second_phase:
			if is_on_floor() && !landed:
				velocity.x = 0
				landed = true
			velocity.y += fall_gravity * delta
			if landed && count == 0:
				animated_sprite_2d.play("stacking_boss")
				count += 1
			if can_attack:
				choose_attack()
			if num_of_attacks > 0:
				print(num_of_attacks)
				var choose_height = rng.randi_range(0,2)
				var bullets = bullet.instantiate()
				#match choose_height:
					#0: 
						#var bullets = bullet.instantiate()
						#bullets.position.y = 1224
					#1:
						#var bullets = bullet.instantiate()
						#bullets.position.y = 2448
					#2:
						#var bullets = bullet.instantiate()
						#bullets.position.y = 3672
				self.add_child(bullets)
				num_of_attacks -= 1
	move_and_slide()

func choose_attack():
	boss_has_exit = false
	if attack == 1:
		attack_Abel()
	elif attack == 2:
		attack_Seth()
	elif attack == 3:
		attack_Cain()
	elif attack == 4:
		attack_Stacked()

func attack_Abel():
	var direction = player.position.x - position.x
	velocity.x += direction
	velocity.y = jump_velocity
	debug.text = "Abel"
	shockwavePos = 1000.0
	shockwaveNeg = -1000.0
	count = 1
	landed = false
	$IdleTimer.start()
	animated_sprite_2d.play("attack_Abel")

func while_Abel():
	if position.x + shockwavePos < 7740 && can_shockwave && count < 2:
		var shock = shockwave.instantiate()
		shock.position.x += shockwavePos
		#shockwavePos += 2040.0
		self.add_child(shock)
	if position.x + shockwaveNeg > 4640 && can_shockwave && count < 2:
		var shock = shockwave.instantiate()
		shock.position.x += shockwaveNeg
		#shockwaveNeg -= 2040.0
		self.add_child(shock)
	if landed and count == 1:
		animated_shockwave.play("shockwave")
		animated_sprite_2d.play("idle_Abel")
	if can_shockwave:
		count += 1
		can_shockwave = false
		$shockwaveTimer.start()

func attack_Seth():
	var direction = player.position.x - position.x
	animated_sprite_2d.play("attack_Seth")
	if direction < 0:
		velocity.x = -(direction**0) * 2000
	else:
		velocity.x = (direction**0) * 2000
	debug.text = "Seth"
	$IdleTimer.start()

func attack_Cain():
	velocity.y = jump_velocity
	debug.text = "Cain"
	landed = false
	$IdleTimer.start()

func while_Cain():
	if velocity.y > 0:
		if !cain_second_attack:
			animated_sprite_2d.play("attack_Cain")
			velocity.y = 0
			var direction = player.position.x - position.x
			direction = direction * 0.01
			velocity.x = direction * 200 
			var height = 57.0 - position.y
			height = height * 0.01
			velocity.y = height * 200
			cain_second_attack = true
			landed = false

func attack_Stacked():
	num_of_attacks = rng.randi_range(min_attack, max_attack)
	can_attack = false
	$cooldownTimer.start()
	#while num_of_attacks > 0:
		#var choose_height = rng.randi_range(0,2)
		#match choose_height:
			#0: 
				#var bullets = bullet.instantiate()
				#bullets.position.y = 1224
			#1:
				#var bullets = bullet.instantiate()
				#bullets.position.y = 2448
			#2:
				#var bullets = bullet.instantiate()
				#bullets.position.y = 3672
		#num_of_attacks -= 1

func _on_idle_timer_timeout():
	cain_second_attack = false
	if attack == 3:
		attack = 0
	boss_exit()

func _on_area_2d_area_entered(area):
	health -= 10
	if health < 0:
		health = 0
		$IdleTimer.start()
		queue_free()
	if !healthbar == null:
		healthbar._set_health(health)

func boss_exit():
	velocity.y = 500.00 * -20
	boss_has_exit = true
	landed = false
	$cooldownTimer.start()
	is_cooldown = true
	if health <= 25:
		count = 0 
		attack = 4
		$entranceTimer.start(2)
	match attack:
		1:
			animated_sprite_2d.play("idle_Seth")
		2:
			animated_sprite_2d.play("idle_Cain")
		0:
			animated_sprite_2d.play("idle_Abel")

func _on_shockwave_timer_timeout():
	can_shockwave = true

func _on_cooldown_timer_timeout():
	can_attack = true

func _on_entrance_timer_timeout():
	second_phase = true
