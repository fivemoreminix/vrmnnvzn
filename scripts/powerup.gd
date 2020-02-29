extends Area2D

enum Class {
	Powerup,
	Detriment
}

enum Powerup {
	FastShooting,
	PhaseThrough,
	TripleShot
}

enum Detriment {
	ToughEnemies,
	LessHealth,
	WowAccurate, # enemies have homing projectiles
	HomingEnemies # enemies ram into player
}

export(int, "Powerup", "Detriment") var item_class = Class.Powerup
# TODO: make this a tool script and change sprite based upon which type
export(int, "Fast shooting", "Phase-through", "Triple-shot") var powerup_type = 0
export(int, "Tough enemies", "Less health", "Wow, accurate!", "Homing enemies") var detriment_type = 0

func _on_Powerup_area_enter( area ):
	if area.get_name() == "ship":
		area.add_effect(item_class, powerup_type if item_class == Class.Powerup else detriment_type)
#		area.powerup = type # set the type of power up on the ship
#		area.get_node("PowerupTimer").start() # start a countdown until area.power_up is set to "None"
		queue_free() # Remove this powerup from scene
