extends Node2D

signal player_passed


func _on_Area2D_area_enter( area ):
	if area.is_in_group("Player"):
		Globals.get("current_camera").add_trauma(1.0)
		
		emit_signal("player_passed")
