extends Item
class_name HealthItem

export(float, 0.0, 10.0, 0.5) var heal_value = 0.0


func _on_body_entered(body: Node) -> void:
	emit_signal("item_picked_up", body.get_parent(), item_type, heal_value)
	queue_free()
