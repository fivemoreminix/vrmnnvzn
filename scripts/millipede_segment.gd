extends Area2D

func _on_MillipedeSegment_area_enter( area ):
	if area.is_in_group("Enemy") and not area.is_in_group("Godmode"):
		area.destroy()