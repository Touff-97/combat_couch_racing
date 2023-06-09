extends Spatial

const EXPLOSION := preload("res://src/particles/explosion.tscn")
const MISSILE := preload("res://src/items/attacks/missile.tscn")

export(int) onready var player_id setget set_id

export(Resource) var stats setget set_stats

onready var max_health : float = 20.0 setget , get_max_health
export(float, 0.0, 20.0, 0.5) var health = 20.0 setget set_health, get_health

export(bool) var can_boost = false
onready var boost_timer: Timer = $BoostTimer
onready var respawn_timer: Timer = $RespawnTimer

onready var ball: RigidBody = $Ball
onready var car_mesh: Spatial = $CarMesh
onready var ground_ray: RayCast = $CarMesh/GroundRay
onready var remote_transform: RemoteTransform = $CarMesh/SR_Veh_MonsterTruck_Red/RemoteTransform
onready var launcher: Position3D = $CarMesh/Launcher

onready var right_wheel = $CarMesh/SR_Veh_MonsterTruck_Red/SR_Veh_MonsterTruck_Wheel_FR
onready var left_wheel = $CarMesh/SR_Veh_MonsterTruck_Red/SR_Veh_MonsterTruck_Wheel_FL
onready var body_mesh = $CarMesh/SR_Veh_MonsterTruck_Red

export(bool) var show_debug = false

var sphere_offset := Vector3(0, -1.0, 0)
var acceleration := 50.0
var boost := 1.3
var steering := 21.0
var turn_speed := 5.0
var turn_stop_limit := 0.75
var body_tilt := 60.0

var move_direction
var speed_input := 0.0
var rotate_input := 0.0

signal car_destroyed
signal boost_burned(player)
signal health_changed
signal boosting(is_boost)
signal missile_fired


func set_id(new_id: int) -> void:
	player_id = new_id


func set_stats(new_stats: Resource) -> void:
	stats = new_stats
	
	stats.connect("health_boosted", self, "_on_health_boosted")
	stats.connect("speed_boosted", self, "_on_speed_boosted")
	stats.connect("attack_item_used", self, "_on_attack_item_used")
	stats.connect("defense_item_used", self, "_on_defense_item_used")


func set_health(new_health: float) -> void:
	print(health)
	health += new_health
	health = clamp(health, 0.0, 20.0)
	print(health)
	
	if health < 1.0:
		emit_signal("car_destroyed")


func get_health() -> float:
	return health


func get_max_health() -> float:
	return max_health


func _ready():
	$Ball/DebugMesh.visible = show_debug
	ground_ray.add_exception(ball)


func _process(delta: float) -> void:
	if player_id != str(name).to_int():
		return
	
	if Input.is_action_just_pressed("explode%s" % str(player_id)):
		emit_signal("car_destroyed")
	
	# Only steer when on ground
	if not ground_ray.is_colliding():
		return
	
	move_direction = sign(ball.linear_velocity.normalized().dot(car_mesh.transform.basis.z))
	
	# Engine force
	speed_input = 0
	speed_input -= Input.get_action_strength("accel%s" % str(player_id))
	speed_input += Input.get_action_strength("brake%s" % str(player_id))
	
	if Input.is_action_just_pressed("attack%s" % str(player_id)) \
			and stats.can_attack:
				stats.attack_item.launcher = ball
				launcher.add_child(stats.attack_item)
				emit_signal("missile_fired")
	
	if Input.is_action_pressed("boost%s" % str(player_id)) \
			and can_boost \
			and move_direction > 0:
		
		emit_signal("boosting", true)
		
		speed_input *= acceleration * boost
		
		$CarMesh/BoostFire.emitting = true
		$CarMesh/BoostFire2.emitting = true
		
		if boost_timer.is_stopped():
			boost_timer.start(0.3)
	else:
		emit_signal("boosting", false)
		
		speed_input *= acceleration
		
		$CarMesh/BoostFire.emitting = false
		$CarMesh/BoostFire2.emitting = false
		
		if not boost_timer.is_stopped():
			boost_timer.stop()
	
	# Steering
	rotate_input = 0
	rotate_input += Input.get_action_strength("left%s" % str(player_id))
	rotate_input -= Input.get_action_strength("right%s" % str(player_id))
	rotate_input *= deg2rad(steering)
	
	# Wheel rotation
	right_wheel.rotation.y = rotate_input
	left_wheel.rotation.y = rotate_input
	
	# Smoke effect
	var d = ball.linear_velocity.normalized().dot(car_mesh.transform.basis.z)
	if ball.linear_velocity.length() > 5.5 and d < 0.9:
		$CarMesh/Smoke.emitting = true
		$CarMesh/Smoke2.emitting = true
	else:
		$CarMesh/Smoke.emitting = false
		$CarMesh/Smoke2.emitting = false
	
	# Car mesh rotation
	if ball.linear_velocity.length() > turn_stop_limit:
		var rotation_dir = 0
		
		# Invert steering for accelerating and reversing
		if move_direction > 0:
			rotation_dir = rotate_input
		else:
			rotation_dir = -rotate_input
		
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, rotation_dir)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		
		# Tilt effect
		var t = -rotate_input * ball.linear_velocity.length() / body_tilt
		body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 10 * delta)
	
	# Allign to ground normal
	var n = ground_ray.get_collision_normal()
	var xform = align_with_y(car_mesh.global_transform, n.normalized())
	car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10 * delta)


func _physics_process(delta):
	car_mesh.transform.origin.x = ball.transform.origin.x + sphere_offset.x
	car_mesh.transform.origin.z = ball.transform.origin.z + sphere_offset.z
	car_mesh.transform.origin.y = lerp(car_mesh.transform.origin.y, ball.transform.origin.y + sphere_offset.y - 0.5, 10 * delta)
	
	ball.add_central_force(-car_mesh.global_transform.basis.z * speed_input)


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func _on_health_boosted(amount: float) -> void:
	set_health(amount)


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
	car_mesh.set_visible(false)
	set_process(false)
	set_physics_process(false)
	explode()


func explode() -> void:
	var new_explosion := EXPLOSION.instance()
	ball.mode = ball.MODE_STATIC
	ball.add_child(new_explosion, true)
	new_explosion.emitting = true
	
	can_boost = false
	
	respawn_timer.start()


func _on_RespawnTimer_timeout() -> void:
	car_mesh.set_visible(true)
	set_process(true)
	set_physics_process(true)
	ball.mode = ball.MODE_RIGID
	
	stats.set_speed(stats.get_speed()-stats.get_speed())


func take_damage(damage: float) -> void:
	print(damage)
	set_health(-damage)
	emit_signal("health_changed")
