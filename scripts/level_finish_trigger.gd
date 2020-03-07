extends Area2D

signal level_finished

func _on_LevelFinishTrigger_area_enter( area ):
	print("area entered")
	if area.is_in_group("Player"):
		print("area Player entered")
		emit_signal("level_finished")
