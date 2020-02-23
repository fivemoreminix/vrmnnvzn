extends Area2D

# TODO: make this a tool script and change sprite based upon which type
export(String, "Shot", "FireRate", "Blah") var type = "Shot"

func _on_Powerup_area_enter( area ):
	if area.get_name() == "ship":
		area.powerup = type # set the type of power up on the ship
		area.get_node("PowerupTimer").start() # start a countdown until area.power_up is set to "None"
		queue_free() # Remove this powerup from scene
