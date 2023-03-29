extends Item
class_name AttackItem

const MISSILE := preload("res://src/items/attacks/missile.tscn")

export(String) var item_name = "missile"
export(int) var ammo_quantity = 1
export(float) var cooldown = 0.2
export(bool) var can_spray = false 


func _on_body_entered(body: Node) -> void:
	var item_scene = MISSILE.instance()
	item_scene.icon = load("res://src/assets/icons/attacks/missile.png")
	item_scene.ammo = ammo_quantity
	item_scene.cooldown = cooldown
	item_scene.can_spray = can_spray
	print(item_scene)
	emit_signal("item_picked_up", body.get_parent(), item_type, ammo_quantity, item_scene)
	queue_free()
