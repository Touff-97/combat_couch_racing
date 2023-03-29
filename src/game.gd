extends Spatial

onready var player_1: Spatial = $"Viewports/Player1Viewport/Player1_View/Level/0"
onready var player_2: Spatial = $"Viewports/Player1Viewport/Player1_View/Level/1"

onready var p1_camera: Spatial = $Viewports/Player1Viewport/Player1_View/CameraOrigin
onready var p2_camera: Spatial = $Viewports/Player2Viewport/Player2_View/CameraOrigin

onready var player_1ui: Control = $GUI/Players/Player_1UI
onready var player_2ui: Control = $GUI/Players/Player_2UI

onready var player_1_viewport: ViewportContainer = $Viewports/Player1Viewport
onready var player_2_viewport: ViewportContainer = $Viewports/Player2Viewport
onready var player_1_view: Viewport = $Viewports/Player1Viewport/Player1_View
onready var player_2_view: Viewport = $Viewports/Player2Viewport/Player2_View
onready var border: ColorRect = $Viewports/Border



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


func _on_item_picked_up(target: Spatial, type: int, value: float = 1.0, item: Spatial = null) -> void:
	match type:
		0: # Heal item
			print(value)
			target.stats.set_health(value)
			
			update_health_ui(target)
		
		1: # Attack item
			target.stats.set_attack_item(item)
			
			update_attack_item(target, item.icon)
		
		2: # Defense item
			target.stats.set_defense_item(item)
		
		3: # Speed item
			target.stats.set_speed(value)
			
			update_speed_ui(target)
		
		_:
			return


func _on_player_boost_burned(player: Spatial) -> void:
	update_speed_ui(player)


func update_health_ui(target: Spatial) -> void:
	get_node("GUI/Players/Player_%sUI" % str(target.player_id + 1)).set_health_value(target.get_health())


func update_speed_ui(target: Spatial) -> void:
	get_node("GUI/Players/Player_%sUI" % str(target.player_id + 1)).set_speed_value(target.stats.get_speed())


func update_attack_item(target: Spatial, item_icon: Texture) -> void:
	get_node("GUI/Players/Player_%sUI/" % str(target.player_id + 1)).set_attack_item(item_icon)


func _on_0_car_destroyed() -> void:
	player_1ui.dead_view_1_animation.play("respawn")
	player_1ui.dead_label.show()
	player_1ui.dead_timer.start()


func _on_1_car_destroyed() -> void:
	player_2ui.dead_view_2_animation.play("respawn")
	player_2ui.dead_label.show()
	player_2ui.dead_timer.start()


func _on_MainMenu_players_changed(amount: int) -> void:
	if amount == 1:
		player_1ui.show()
		player_1_viewport.show()
		
		player_2ui.hide()
		player_2_viewport.hide()
		
		player_2.hide()
		
		border.hide()
		
		player_1_view.size.x = 1920
	else:
		player_1ui.show()
		player_1_viewport.show()
		
		player_2ui.show()
		player_2_viewport.show()
		
		player_2.show()
		
		border.show()
		
		
		player_1_view.size.x = 955
		player_2_view.size.x = 955


func _on_0_health_changed() -> void:
	update_health_ui(player_1)


func _on_1_health_changed() -> void:
	update_health_ui(player_2)


func _on_0_boosting(is_boost) -> void:
	if is_boost:
		$Viewports/Player1Viewport/Player1_View/CameraOrigin/Camera.fov = 80
	else:
		$Viewports/Player1Viewport/Player1_View/CameraOrigin/Camera.fov = 70


func _on_1_boosting(is_boost) -> void:
	if is_boost:
		$Viewports/Player2Viewport/Player2_View/CameraOrigin/Camera.fov = 80
	else:
		$Viewports/Player2Viewport/Player2_View/CameraOrigin/Camera.fov = 70


func _on_0_missile_fired() -> void:
	update_attack_item(player_1, null)


func _on_1_missile_fired() -> void:
	update_attack_item(player_2, null)
