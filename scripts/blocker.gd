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
			# Play explosion animation
			# ...
			# Play explosion sound
			# get_node("sfx").play("shroom_destroy")
			
			# Hurt nearby enemies / player
			# ...
			return true
	return false


func _on_VisibilityNotifier2D_exit_screen():
	queue_free()
