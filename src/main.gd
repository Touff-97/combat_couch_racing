extends Spatial

onready var player_1: Spatial = $Viewports/PlayerViewport0/Viewport/Players/Player_0
onready var player_2: Spatial = $Viewports/PlayerViewport0/Viewport/Players/Player_1

onready var p1_camera: Spatial = $Viewports/PlayerViewport0/Viewport/CameraOrigin
onready var p2_camera: Spatial = $Viewports/PlayerViewport1/Viewport/CameraOrigin

onready var player_1ui: Control = $GUI/Players/Player_0
onready var player_2ui: Control = $GUI/Players/Player_1

onready var player_1_viewport: ViewportContainer = $Viewports/PlayerViewport0
onready var player_2_viewport: ViewportContainer = $Viewports/PlayerViewport1
onready var player_1_view: Viewport = $Viewports/PlayerViewport0/Viewport
onready var player_2_view: Viewport = $Viewports/PlayerViewport1/Viewport
onready var border: ColorRect = $Viewports/Border


func _ready() -> void:
	player_1.remote_transform.remote_path = p1_camera.get_path()
	player_2.remote_transform.remote_path = p2_camera.get_path()
	
	for player in get_tree().get_nodes_in_group("player"):
		var new_stats = Stats.new()
		player.stats = new_stats
	
	player_1ui.set_health_value(player_1.get_node("HealthComponent").get_health())
	player_2ui.set_health_value(player_2.get_node("HealthComponent").get_health())
	
	player_1ui.set_speed_value(player_1.stats.get_speed())
	player_2ui.set_speed_value(player_2.stats.get_speed())
	
	for item in get_tree().get_nodes_in_group("pick_up"):
		item.connect("item_picked_up", self, "_on_item_picked_up")


func _on_item_picked_up(target: Spatial, type: int, value: float = 1.0, item: Spatial = null) -> void:
	match type:
		0: # Heal item
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


func _on_health_changed(player: int) -> void:
	var target = get_node("Viewports/PlayerViewport0/Viewport/Players/Player_%s" % str(player))
	
	update_health_ui(target)


func _on_player_boosting(is_boost: bool, player_id: int) -> void:
	var target = get_node("Viewports/PlayerViewport0/Viewport/Players/Player_%s" % str(player_id))
	var camera = get_node("Viewports/PlayerViewport%s/Viewport/CameraOrigin/Camera" % str(player_id))
	
	update_speed_ui(target)
	
	if is_boost:
		camera.fov = 80
	else:
		camera.fov = 70


func _on_player_atacked(player: int) -> void:
	var target = get_node("Viewports/PlayerViewport0/Viewport/Players/Player_%s" % str(player))
	
	update_attack_item(target, null)


func update_health_ui(target: Spatial) -> void:
	get_node("GUI/Players/Player_%s" % str(target.player_id)).set_health_value(target.get_node("HealthComponent").get_health())


func update_speed_ui(target: Spatial) -> void:
	get_node("GUI/Players/Player_%s" % str(target.player_id)).set_speed_value(target.stats.get_speed())


func update_attack_item(target: Spatial, item_icon: Texture) -> void:
	get_node("GUI/Players/Player_%s/" % str(target.player_id)).set_attack_item(item_icon)


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
