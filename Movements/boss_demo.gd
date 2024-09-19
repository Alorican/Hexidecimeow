extends Node2D

static var bossBattle: bool = false
@onready var mainCamera: Camera2D = $mainCamera
@onready var bossRoomCamera: Camera2D = $bossRoomCamera
@onready var foreFathers = $ForeFathers
@onready var remoteTransform = $Byrne/RemoteTransform2D
@onready var player = $Byrne
# Called when the node enters the scene tree for the first time.
# Called when the node enters the scene tree for the first time.
func _ready():
	foreFathers.visible = false
	foreFathers.set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(player.position.y)
	#print(player.position.x);
	if foreFathers != null && bossBattle:
		if foreFathers.health <= 0:
			foreFathers.visible = false
			bossBattle = false
			unlock_door()
			CameraTransition.transition_camera2D(player, foreFathers, bossRoomCamera, mainCamera, 2)
			


func _on_area_2d_area_entered(area):
	if !bossBattle:
		print("collided")
		lock_door()
		CameraTransition.transition_camera2D(player, foreFathers, mainCamera, bossRoomCamera, 2)
		foreFathers.visible = true
		bossBattle = true
		
func lock_door() -> void:
	var tileMapPath: NodePath = "./TileMap"
	var tileMap: = get_node(tileMapPath)
	
	tileMap.set_layer_enabled(1, true)
	
func unlock_door() -> void:
	var tileMapPath: NodePath = "./TileMap"
	
	var tileMap: = get_node(tileMapPath)
	
	tileMap.set_layer_enabled(1, false)
