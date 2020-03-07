extends Area2D

export(String, "Powerup", "Detriment") var item_class = "Powerup"
# TODO: make this a tool script and change sprite based upon which type
export(String, "Fast shooting", "Phase-through", "Triple-shot") var powerup_type = "Fast shooting"
export(String, "Tough enemies", "Less health", "Wow, accurate!", "Homing enemies") var detriment_type = "Tough enemies"

func _on_Powerup_area_enter( area ):
	if area.get_name() == "ship":
		area.add_effect(item_class, powerup_type if item_class == "Powerup" else detriment_type)
		queue_free() # Remove this powerup from scene
