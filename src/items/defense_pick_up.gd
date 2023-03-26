extends Item
class_name DefenseItem

export(String) var item_name = ""
export(int) var quantity = 1


func _on_body_entered(body: Node) -> void:
	var item_scene = load("res://src/items/defenses/%s.tscn" % item_name).instance()
	item_scene.icon = load("res://src/assets/icons/defenses/%s.png" % item_name)
	item_scene.quantity = quantity
	emit_signal("item_picked_up", body.get_parent(), item_type, quantity, item_scene)
	queue_free()
