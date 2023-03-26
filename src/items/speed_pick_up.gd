extends Item
class_name SpeedItem

export(float, 0.0, 10.0) var speed_value = 0.0


func _on_body_entered(body: Node) -> void:
	emit_signal("item_picked_up", body.get_parent(), item_type, speed_value)
	queue_free()
