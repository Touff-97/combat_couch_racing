extends VehicleBody

export(int) onready var player_id = 0

enum DeviceType {
	KEYBOARD,
	CONTROLLER,
}

var device_type : int = DeviceType.CONTROLLER

enum Buttons {
	ACCELERATE,
	START,
	BRAKE,
	BACK,
}

var is_acceleration : bool = false

var max_rpm : float = 350.0
var max_torque : float = 200.0

onready var wheel_fl: VehicleWheel = $Wheel_FL
onready var wheel_fr: VehicleWheel = $Wheel_FR
onready var wheel_bl: VehicleWheel = $Wheel_BL
onready var wheel_br: VehicleWheel = $Wheel_BR


func _input(event: InputEvent) -> void:
	if event.get_device() == player_id:
		if Input.is_joy_button_pressed(player_id, Buttons.ACCELERATE) \
		or Input.is_action_pressed("accel" + self.name):
			is_acceleration = true
		else:
			is_acceleration = false
		
		if Input.is_action_just_pressed("change"):
			device_type = !device_type
			print(device_type)


func _physics_process(delta: float) -> void:
	if device_type:
		steering = lerp(steering, -Input.get_joy_axis(player_id, 0) * 0.4, 5 * delta)
	else:
		steering = lerp(steering, Input.get_axis("right" + self.name, "left" + self.name) * 0.4, 5 * delta)

	if is_acceleration:
		wheel_bl.engine_force = lerp(wheel_bl.engine_force, get_wheel_force(wheel_bl, 100.0), delta)
		wheel_br.engine_force = lerp(wheel_br.engine_force, get_wheel_force(wheel_br, 100.0), delta)
	else:
		wheel_bl.engine_force = lerp(wheel_bl.engine_force, get_wheel_force(wheel_bl, 0.0), 2 * delta)
		wheel_br.engine_force = lerp(wheel_br.engine_force, get_wheel_force(wheel_br, 0.0), 2 * delta)
	
	print("(%s, %s)" % [wheel_bl.engine_force, wheel_br.engine_force])


func get_wheel_force(wheel: VehicleWheel, acceleration: float) -> float:
	var rpm = wheel.get_rpm()
	return acceleration * max_torque * (1 - abs(rpm) / max_rpm)
	
