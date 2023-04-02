extends RigidBody

export(NodePath) onready var player = get_node(player)

var sphere_offset := Vector3(0, -1.0, 0)
var acceleration := 50.0
var boost := 1.3
var steering := 21.0
var turn_speed := 5.0
var turn_stop_limit := 0.75
var body_tilt := 180.0

var move_direction
var speed_input := 0.0
var rotate_input := 0.0


func _process(delta: float) -> void:
	if player.player_id != str(player.name).to_int():
		return
	
	# Only steer when on ground
	if not player.ground_ray.is_colliding():
		return
	
	move_direction = sign(linear_velocity.normalized() \
						.dot(player.mesh_body.transform.basis.z))
	
	# Engine force
	speed_input = 0
	speed_input -= Input.get_action_strength("accel%s" % str(player.player_id))
	speed_input += Input.get_action_strength("brake%s" % str(player.player_id))
	
	if Input.is_action_pressed("boost%s" % str(player.player_id)) \
			and player.can_boost \
			and move_direction > 0:
		speed_input *= acceleration * boost
	else:
		speed_input *= acceleration
	
	# Steering
	rotate_input = 0
	rotate_input += Input.get_action_strength("left%s" % str(player.player_id))
	rotate_input -= Input.get_action_strength("right%s" % str(player.player_id))
	rotate_input *= deg2rad(steering)
	
	# Wheel rotation
	player.right_wheel.rotation.y = rotate_input
	player.left_wheel.rotation.y = rotate_input
	
	# Car mesh rotation
	if linear_velocity.length() > turn_stop_limit:
		var rotation_dir = 0
		
		# Invert steering for accelerating and reversing
		if move_direction > 0:
			rotation_dir = rotate_input
		else:
			rotation_dir = -rotate_input
		
		var new_basis = player.mesh_body.global_transform.basis \
						.rotated(player.mesh_body.global_transform.basis.y, rotation_dir)
		player.mesh_body.global_transform.basis = player.mesh_body.global_transform.basis \
													.slerp(new_basis, turn_speed * delta)
		player.mesh_body.global_transform = player.mesh_body.global_transform.orthonormalized()
		
		# Tilt effect
		var t = -rotate_input * linear_velocity.length() / body_tilt
		player.car_body.rotation.z = lerp(player.car_body.rotation.z, t, 10 * delta)
	
	# Allign to ground normal
	var n = player.ground_ray.get_collision_normal()
	var xform = align_with_y(player.mesh_body.global_transform, n.normalized())
	player.mesh_body.global_transform = player.mesh_body.global_transform \
										.interpolate_with(xform, 10 * delta)


func _physics_process(delta):
	player.mesh_body.transform.origin.x = transform.origin.x + sphere_offset.x
	player.mesh_body.transform.origin.z = transform.origin.z + sphere_offset.z
	player.mesh_body.transform.origin.y = lerp(player.mesh_body.transform.origin.y, transform.origin.y + sphere_offset.y, 10 * delta)
	
	add_central_force(-player.mesh_body.global_transform.basis.z * speed_input)


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
