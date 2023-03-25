extends Spatial

onready var player_1: Spatial = $"HBox/Player1Viewport/Viewport/Level/0"
onready var player_2: Spatial = $"HBox/Player1Viewport/Viewport/Level/1"

onready var p1_camera: Spatial = $HBox/Player1Viewport/Viewport/CameraOrigin
onready var p2_camera: Spatial = $HBox/Player2Viewport/Viewport/CameraOrigin


func _ready() -> void:
	player_1.remote_transform.remote_path = p1_camera.get_path()
	player_2.remote_transform.remote_path = p2_camera.get_path()
	
	p1_camera.translation = Vector3(0, 4, -7)
