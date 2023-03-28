extends CPUParticles

func _on_FreeTimer_timeout() -> void:
	queue_free()
