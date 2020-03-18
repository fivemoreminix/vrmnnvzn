extends Node2D

func _ready():
	expand_beam()
#	get_node("TimerWhileOff").start()
	_on_TimerWhileOn_timeout() # Disable collisions and start TimerWhileOff


func expand_beam():
	var scale = Vector2(get_node("RightHead").get_pos().x-5, 1)
	get_node("LeftHead/Beam/Sprite").set_scale(scale)
	get_node("LeftHead/Beam/CollisionShape2D").set_scale(scale)
	get_node("LeftHead/Beam/CollisionShape2D").set_pos(Vector2(scale.x/2, scale.y)) # colliders scale from middle, so we offset it here
	
	get_node("ChargeTex").set_size(scale)


func _on_VisibilityEnabler2D_exit_screen():
	print(get_name() + " has left the screen... freeing self :'(")
	queue_free()


func _on_TimerWhileOff_timeout(): # After being off ...
	# Begin playing "charging" animation
	# Start charging timer
	
	# TODO: anim...
	get_node("TimerWhileCharging").start()
	get_node("AnimationPlayer").play("Charging") # Start animation


func _on_TimerWhileCharging_timeout(): # After fully charging ...
	# show beam
	# enable beam collisions
	
	get_node("LeftHead/Beam").show()
	get_node("LeftHead/Beam").set_monitorable(true)
	
	get_node("TimerWhileOn").start()
	get_node("AnimationPlayer").stop() # Stop animation


func _on_TimerWhileOn_timeout(): # After being on ...
	# stop showing the beam
	# disable beam collisions
	
	get_node("LeftHead/Beam").hide()
	get_node("LeftHead/Beam").set_monitorable(false) # Collider cannot be seen by other areas
	
	get_node("TimerWhileOff").start()
