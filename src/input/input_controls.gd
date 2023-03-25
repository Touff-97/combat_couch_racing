extends Resource
class_name InputControl

export var player : String = "0"
export var direction : Vector3

onready var accelerate : String = "accelerate" + player
onready var brake : String = "reverse0" + player
onready var left : String = "left0" + player
onready var right : String = "right0" + player

signal car_accelerated(is_accel)
signal car_braked(is_stop)
signal car_reversed(is_rever)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(accelerate):
		emit_signal("car_accelerated", true)
	else:
		emit_signal("car_accelerated", false)
	
	if Input.is_action_just_pressed(brake):
		emit_signal("car_braked", true)
	else:
		emit_signal("car_braked", false)
