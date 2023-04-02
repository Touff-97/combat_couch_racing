extends Node

onready var max_health : float = 20.0 setget , get_max_health
export(float, 0.0, 20.0, 0.5) var health = 20.0 setget set_health, get_health

signal no_health
signal health_changed


func set_health(new_health: float) -> void:
	health += new_health
	health = clamp(health, 0.0, 20.0)
	
	if health <= 0.0:
		emit_signal("no_health")


func get_health() -> float:
	return health


func get_max_health() -> float:
	return max_health


func take_damage(damage: float) -> void:
	set_health(-damage)
	emit_signal("health_changed")
