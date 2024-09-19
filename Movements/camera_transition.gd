extends Node

@onready var camera2D: Camera2D = $Camera2D

var transitioning: bool = false

func _ready() -> void:
	camera2D.enabled = false

func switch_camera(from, to) -> void:
	from.enabled = false
	to.enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func transition_camera2D(player, boss, from: Camera2D, to: Camera2D, duration: float = 1.0) -> void:
	if transitioning: return
	# Copy the parameters of the first camera
	camera2D.zoom = from.zoom
	camera2D.offset = from.offset
	camera2D.light_mask = from.light_mask

	# Move our transition camera to the first camera position
	camera2D.global_transform = from.global_transform
	
	# Make our transition camera current
	camera2D.enabled = true
	from.enabled = false
	
	transitioning = true
	
	# Move to the second camera, while also adjusting the parameters to
	# match the second camera
	#tween.remove_all()
	#tween.interpolate_property(camera2D, "global_transform", camera2D.global_transform, 
		#to.global_transform, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	#tween.interpolate_property(camera2D, "zoom", camera2D.zoom, 
		#to.zoom, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	#tween.interpolate_property(camera2D, "offset", camera2D.offset, 
		#to.offset, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	#tween.start()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera2D, "global_transform", to.global_transform, duration).from(camera2D.global_transform)
	tween.tween_property(camera2D, "zoom", to.zoom, duration).from(camera2D.zoom)
	tween.tween_property(camera2D, "offset", to.offset, duration).from(camera2D.offset)

	player.set_physics_process(false)
	boss.set_physics_process(false)
	# Wait for the tween to complete
	await tween.finished
	camera2D.enabled = false
	to.enabled = true
	transitioning = false
	
	player.set_physics_process(true)
	boss.set_physics_process(true)
	# Make the second camera 
	
