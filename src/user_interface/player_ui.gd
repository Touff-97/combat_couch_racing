extends Control

export(float) var health_value setget set_health_value, get_health_value
export(float) var speed_value setget set_speed_value, get_speed_value

onready var health_defense: VBoxContainer = $Margin/BottomUI/HealthDefense
onready var speed_attack: VBoxContainer = $Margin/BottomUI/SpeedAttack


func set_health_value(new_health_value: float) -> void:
	health_value = new_health_value
	
	health_defense.get_child(0).value = health_value


func get_health_value() -> float:
	return health_value


func set_speed_value(new_speed_value: float) -> void:
	speed_value = new_speed_value
	
	speed_attack.get_child(0).value = speed_value


func get_speed_value() -> float:
	return speed_value
