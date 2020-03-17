extends Area2D

# TODO: make this a tool script and change sprite based upon which type
export(String, "Fast shooting", "Phase-through", "Triple-shot", "Shoot diag") var powerup = "Fast shooting"

func _on_Powerup_area_enter( area ):
	if area.get_name() == "ship":
		area.add_effect(powerup)
		queue_free() # Remove this powerup from scene
