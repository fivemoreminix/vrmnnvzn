extends Control

signal flash_finished

func flash(button_rect):
	show() # make self visible
	get_tree().get_root().set_disable_input(true) # prevent input while doing animation
	get_node("White").set_global_pos(button_rect.pos)
	get_node("White").set_size(button_rect.size)
	get_node("Animator").play("flash")


func _on_Animator_finished():
	# reset state
	hide()
	get_tree().get_root().set_disable_input(false)
	
	emit_signal("flash_finished")
	
	for conn in get_signal_connection_list("flash_finished"): # Clear every connection to this signal after emitting it
		disconnect(conn["signal"], conn.target, conn.method)
