extends Area2D

var health = 2
var destroyed = false

func destroy():
	if not destroyed:
		health -= 1
		
		if health <= 0:
			set_monitorable(false)
			get_node("AnimatedSprite").play("destroyed")
			get_node("sfx").play("shroom_destroy")


func _on_VisibilityNotifier2D_exit_screen():
	queue_free()
