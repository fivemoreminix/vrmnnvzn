extends Control

signal flash_finished

func flash(button_rect):
	show() # make self visible
	get_node("White").show()
	get_tree().get_root().set_disable_input(true) # prevent input while doing animation
	get_node("White").edit_set_rect(button_rect)
	get_node("Animator").play("flash")
	print(get_node("Animator").get_pos())


func _on_Animator_finished():
	# reset state
	hide()
	get_tree().get_root().set_disable_input(false)
	get_node("Animator").seek(0)
	
	emit_signal("flash_finished")
