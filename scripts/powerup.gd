extends Area2D

# TODO: make this a tool script and change sprite based upon which type
export(String, "Random", "Fast shooting", "Phase-through", "Triple-shot", "Shoot diag", "Double-shot") var powerup = "Random"

func _on_Powerup_area_enter( area ):
	if area.get_name() == "ship":
		# Powerups for bullets last until you die
		area.add_effect(powerup, 300 if powerup != "Phase-through" else 10)
		queue_free() # Remove this powerup from scene

func _ready():
	if powerup == "Random":
		var n = randi() % 5
		if   n == 0: powerup = "Fast shooting"
		elif n == 1: powerup = "Phase-through"
		elif n == 2: powerup = "Triple-shot"
		elif n == 3: powerup = "Shoot diag"
		elif n == 4: powerup = "Double-shot"
