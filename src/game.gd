extends Spatial

onready var player_1: Spatial = $"Viewports/Player1Viewport/Viewport/Level/0"
onready var player_2: Spatial = $"Viewports/Player1Viewport/Viewport/Level/1"

onready var p1_camera: Spatial = $Viewports/Player1Viewport/Viewport/CameraOrigin
onready var p2_camera: Spatial = $Viewports/Player2Viewport/Viewport/CameraOrigin

onready var player_1ui: Control = $GUI/HBox/Player_1UI
onready var player_2ui: Control = $GUI/HBox/Player_2UI

func _ready() -> void:
	player_1.remote_transform.remote_path = p1_camera.get_path()
	player_2.remote_transform.remote_path = p2_camera.get_path()
	
	for player in get_tree().get_nodes_in_group("player"):
		var new_stats = Stats.new()
		player.stats = new_stats
	
	player_1ui.set_health_value(player_1.get_health())
	player_2ui.set_health_value(player_2.get_health())
	
	player_1ui.set_speed_value(player_1.stats.get_speed())
	player_2ui.set_speed_value(player_2.stats.get_speed())
	
	for item in get_tree().get_nodes_in_group("pick_up"):
		item.connect("item_picked_up", self, "_on_item_picked_up")


func _on_item_picked_up(target: Spatial, type: int, value: float = 1.0, item: PackedScene = null) -> void:
	match type:
		0: # Heal item
			target.stats.set_health(value)
			
			update_health_ui(target)
		
		1: # Attack item
			target.stats.set_attack_item(item)
		
		2: # Defense item
			target.stats.set_defense_item(item)
		
		3: # Speed item
			target.stats.set_speed(value)
			
			print("speed item")
			
			update_speed_ui(target)
		
		_:
			return


func _on_player_boost_burned(player: Spatial) -> void:
	update_speed_ui(player)


func update_health_ui(target: Spatial) -> void:
	get_node("GUI/HBox/Player_%sUI" % str(target.player_id + 1)).set_health_value(target.get_health())


func update_speed_ui(target: Spatial) -> void:
	get_node("GUI/HBox/Player_%sUI" % str(target.player_id + 1)).set_speed_value(target.stats.get_speed())
