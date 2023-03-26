extends Resource
class_name Stats

export(float) var health_boost = 0.0 setget set_health
export(float) var speed_boost = 0.0 setget set_speed, get_speed

export(PackedScene) var attack_item setget set_attack_item
export(PackedScene) var defense_item setget set_defense_item

var can_attack : bool = false
var can_defend : bool = false
var can_speed : bool = false

signal health_boosted(amount)
signal speed_boosted(amount)

signal attack_item_used(item)
signal defense_item_used(item)


func set_health(new_health: float) -> void:
	health_boost = new_health
	
	emit_signal("health_boosted", health_boost)
	health_boost = 0


func set_speed(new_speed: float) -> void:
	speed_boost = new_speed
	
	if speed_boost > 0.0:
		can_speed = true
	else:
		can_speed = false
	
	emit_signal("speed_boosted", speed_boost)


func get_speed() -> float:
	return speed_boost


func set_attack_item(new_item: PackedScene) -> void:
	attack_item = new_item
	
	if attack_item:
		can_attack = true
	else:
		can_attack = false


func set_defense_item(new_item: PackedScene) -> void:
	defense_item = new_item
	
	if defense_item:
		can_defend = true
	else:
		can_defend = false


func is_attack() -> bool:
	return can_attack


func is_defense() -> bool:
	return can_defend


func is_speed() -> bool:
	return can_speed


func use_attack_item() -> void:
	emit_signal("attack_item_used", attack_item)
	
	attack_item.ammo -= 1
	
	if attack_item.ammo < 1:
		set_attack_item(null)


func use_defense_item() -> void:
	emit_signal("defense_item_used", defense_item)
	
	defense_item.quantity -= 1
	
	if defense_item.quantity < 1:
		set_defense_item(null)
