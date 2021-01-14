extends Area2D

#var radius = 5
#var damage = 5

var health = 1
var destroyed = false

func destroy():
	if not destroyed:
		health -= 1
		
		if health <= 0:
			set_monitorable(false)
			get_node("Sprite").set_texture(preload("res://assets/sprites/barrels/barrel_destroyed.png"))
			get_node("Particles2D").set_emitting(true)
			
			
			# Play explosion sound
			# get_node("sfx").play("shroom_destroy")
			
			get_node("DamageRadius").destroy_nearby_entities()
			
			return true
	return false


func _on_VisibilityNotifier2D_exit_screen():
	queue_free()
