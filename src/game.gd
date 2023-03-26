extends Spatial

onready var player_1: Spatial = $"HBox/Player1Viewport/Viewport/Level/0"
onready var player_2: Spatial = $"HBox/Player1Viewport/Viewport/Level/1"

onready var p1_camera: Spatial = $HBox/Player1Viewport/Viewport/CameraOrigin
onready var p2_camera: Spatial = $HBox/Player2Viewport/Viewport/CameraOrigin


func _ready() -> void:
	player_1.remote_transform.remote_path = p1_camera.get_path()
	player_2.remote_transform.remote_path = p2_camera.get_path()
	
	for player in get_tree().get_nodes_in_group("player"):
		var new_stats = Stats.new()
		player.stats = new_stats
	
	for item in get_tree().get_nodes_in_group("pick_up"):
		item.connect("item_picked_up", self, "_on_item_picked_up")


func _on_item_picked_up(target: Spatial, type: int, value: float = 1.0, item: PackedScene = null) -> void:
	match type:
		0: # Heal item
			target.stats.set_health(value)
		
		1: # Attack item
			target.stats.set_attack_item(item)
		
		2: # Defense item
			target.stats.set_defense_item(item)
		
		3: # Speed item
			target.stats.set_speed(value)
		
		_:
			return
