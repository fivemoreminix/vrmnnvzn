extends Area2D

signal level_finished

func _on_LevelFinishTrigger_area_enter( area ):
	if area.is_in_group("Player"):
		print("Player entered level finish trigger")
		emit_signal("level_finished")
