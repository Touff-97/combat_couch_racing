extends Spatial

export(int) onready var player_id setget set_id

export(Resource) var stats setget set_stats

onready var ball: RigidBody = $Ball
onready var car_mesh: Spatial = $CarMesh
onready var ground_ray: RayCast = $CarMesh/GroundRay
onready var remote_transform: RemoteTransform = $CarMesh/SR_Veh_SprintCar_Blue/RemoteTransform
onready var shadow: MeshInstance = $CarMesh/Shadow

onready var right_wheel = $CarMesh/SR_Veh_SprintCar_Blue/SR_Veh_StockCar_Wheel_FR
onready var left_wheel = $CarMesh/SR_Veh_SprintCar_Blue/SR_Veh_StockCar_Wheel_FL
onready var body_mesh = $CarMesh/SR_Veh_SprintCar_Blue

export(bool) var show_debug = false

var sphere_offset := Vector3(0, -1.0, 0)
var acceleration := 50.0
var steering := 21.0
var turn_speed := 5.0
var turn_stop_limit := 0.75
var body_tilt := 60.0

var speed_input := 0.0
var rotate_input := 0.0


func set_id(new_id: int) -> void:
	player_id = new_id


func set_stats(new_stats: Resource) -> void:
	stats = new_stats
	
	stats.connect("health_boosted", self, "_on_health_boosted")
	stats.connect("speed_boosted", self, "_on_speed_boosted")
	stats.connect("attack_item_used", self, "_on_attack_item_used")
	stats.connect("defense_item_used", self, "_on_defense_item_used")


func _ready():
	$Ball/DebugMesh.visible = show_debug
	ground_ray.add_exception(ball)


func _process(delta: float) -> void:
	if player_id != str(name).to_int():
		return
	
	# Only steer when on ground
	if not ground_ray.is_colliding():
		shadow.hide()
		return
	
	shadow.show()
	
	# Engine force
	speed_input = 0
	speed_input -= Input.get_action_strength("accel" + str(player_id))
	speed_input += Input.get_action_strength("brake" + str(player_id))
	speed_input *= acceleration
	
	# Steering
	rotate_input = 0
	rotate_input += Input.get_action_strength("left" + str(player_id))
	rotate_input -= Input.get_action_strength("right" + str(player_id))
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
		var move_direction := sign(ball.linear_velocity.normalized().dot(car_mesh.transform.basis.z))
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
	car_mesh.transform.origin.y = lerp(car_mesh.transform.origin.y, ball.transform.origin.y + sphere_offset.y, 10 * delta)
	
	ball.add_central_force(-car_mesh.global_transform.basis.z * speed_input)


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func _on_health_boosted(amount: float) -> void:
	pass


func _on_speed_boosted(amount: float) -> void:
	pass


func _on_attack_item_used(item: PackedScene) -> void:
	pass


func _on_defense_item_used(item: PackedScene) -> void:
	pass
