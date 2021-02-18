extends Area2D

export var damage = 5

var health = 1
var destroyed = false

func destroy():
	if not destroyed:
		health -= 1
		
		if health <= 0:
			set_monitorable(false)
			get_node("Sprite").set_visible(false)
			get_node("Particles2D").set_emitting(true)
			
			# Play explosion sound
			get_node("sfx").play("sound_explode")
			
			get_node("DamageRadius").hurt_nearby_entities(damage)
			
			return true
	return false


func _on_VisibilityNotifier2D_exit_screen():
	queue_free()
