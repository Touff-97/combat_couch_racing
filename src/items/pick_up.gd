extends Area
class_name Item

enum itemType {
	HEAL,
	ATTACK,
	DEFEND,
	SPEED
}

export(int) var item_type = itemType.ATTACK

signal item_picked_up(target, type, value, item)


func _on_body_entered(body: Node) -> void:
	emit_signal("item_picked_up", body.get_parent(), item_type)
	queue_free()
