extends Spatial
class_name Player

const EXPLOSION := preload("res://src/particles/explosion.tscn")
const MISSILE := preload("res://src/items/attacks/missile.tscn")

export(int) onready var player_id setget set_id

export(Resource) var stats setget set_stats

onready var health : Node = $HealthComponent

export(bool) var can_boost = false
onready var boost_timer: Timer = $BoostTimer
onready var respawn_timer: Timer = $RespawnTimer

onready var collision_body: RigidBody = $CollisionBody
onready var mesh_body: Spatial = $MeshBody
onready var ground_ray: RayCast = $MeshBody/GroundRay

var car_body
var right_wheel
var left_wheel
var remote_transform
var launcher

export(bool) onready var show_debug = false

enum CarType {
	DERBY,
	MONSTER,
	MUSCLE,
	OFF_ROAD,
	RACING,
	RALLEY,
	SPRINT,
}

var car_type : int = CarType.SPRINT

signal boosting(is_boost)
signal atacked


func set_id(new_id: int) -> void:
	player_id = new_id


func set_stats(new_stats: Resource) -> void:
	stats = new_stats
	
	stats.connect("health_boosted", self, "_on_health_boosted")
	stats.connect("speed_boosted", self, "_on_speed_boosted")
	stats.connect("attack_item_used", self, "_on_attack_item_used")
	stats.connect("defense_item_used", self, "_on_defense_item_used")


func _ready():
	swap_car(car_type)
	
	$CollisionBody/DebugMesh.visible = show_debug
	ground_ray.add_exception(collision_body)


func _process(delta: float) -> void:
	if player_id != str(name).to_int():
		return
	
	if Input.is_action_just_pressed("explode%s" % str(player_id)):
		emit_signal("car_destroyed")
	
	if Input.is_action_just_pressed("attack%s" % str(player_id)) \
			and stats.can_attack:
		
		stats.attack_item.launcher = collision_body
		launcher.add_child(stats.attack_item)
		emit_signal("missile_fired")
	
	if Input.is_action_pressed("boost%s" % str(player_id)) \
			and can_boost \
			and collision_body.move_direction > 0:
		
		emit_signal("boosting", true)
		
		for child in car_body.get_children():
			if child.is_in_group("boost"):
				child.emitting = true
		
		if boost_timer.is_stopped():
			boost_timer.start(0.3)
	else:
		emit_signal("boosting", false)
		
		for child in car_body.get_children():
			if child.is_in_group("boost"):
				child.emitting = false
		
		if not boost_timer.is_stopped():
			boost_timer.stop()
	
	# Smoke effect
	var d = collision_body.linear_velocity.normalized().dot(mesh_body.transform.basis.z)
	if collision_body.linear_velocity.length() > 5.5 and d < 0.9:
		for child in car_body.get_children():
			if child.is_in_group("smoke"):
				child.emitting = true
	else:
		for child in car_body.get_children():
			if child.is_in_group("smoke"):
				child.emitting = false


func _on_health_boosted(amount: float) -> void:
	health.set_health(amount)


func _on_speed_boosted(can: bool) -> void:
	can_boost = can


func _on_BoostTimer_timeout() -> void:
	stats.set_speed(-1.0)
	emit_signal("boost_burned", self)


func _on_attack_item_used(item: PackedScene) -> void:
	pass


func _on_defense_item_used(item: PackedScene) -> void:
	pass


func _on_car_destroyed() -> void:
	mesh_body.set_visible(false)
	set_process(false)
	set_physics_process(false)
	explode()


func explode() -> void:
	var new_explosion := EXPLOSION.instance()
	collision_body.mode = collision_body.MODE_STATIC
	collision_body.add_child(new_explosion, true)
	new_explosion.emitting = true
	
	can_boost = false
	
	respawn_timer.start()


func _on_RespawnTimer_timeout() -> void:
	mesh_body.set_visible(true)
	set_process(true)
	set_physics_process(true)
	collision_body.mode = collision_body.MODE_RIGID
	
	stats.set_speed(stats.get_speed()-stats.get_speed())
	health.set_health(health.max_health)


func swap_car(car: int) -> void:
	var car_path: String
	
	match car:
		CarType.DERBY:
			car_path = "res://src/vehicles/derby_car.tscn"
		
		CarType.MONSTER:
			car_path = "res://src/vehicles/monster_truck.tscn"
		
		CarType.MUSCLE:
			car_path = "res://src/vehicles/muscle_car.tscn"
		
		CarType.OFF_ROAD:
			car_path = "res://src/vehicles/off_road_truck.tscn"
		
		CarType.RACING:
			car_path = "res://src/vehicles/racing_truck.tscn"
		
		CarType.RALLEY:
			car_path = "res://src/vehicles/ralley_car.tscn"
		
		CarType.SPRINT:
			car_path = "res://src/vehicles/sprint_car.tscn"
	
	var new_car : MeshInstance = load(car_path).instance()
	
	car_body = new_car
	right_wheel = new_car.get_node("Wheel_FR")
	left_wheel = new_car.get_node("Wheel_FL")
	remote_transform = new_car.get_node("RemoteTransform")
	launcher = new_car.get_node("Launcher")
	
	mesh_body.add_child(new_car, true)
