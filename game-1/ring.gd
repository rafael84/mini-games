extends StaticBody3D

signal pin_scored(points: int)

func _on_inner_area_body_entered(body: Node3D) -> void:
	pin_scored.emit(1)
	body.queue_free()
