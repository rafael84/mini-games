extends StaticBody3D


func _on_inner_area_body_entered(body: Node3D) -> void:
	body.queue_free()
