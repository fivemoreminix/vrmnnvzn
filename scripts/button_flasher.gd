extends Control

signal flash_finished

func flash(button_rect):
	show() # make self visible
	get_tree().get_root().set_disable_input(true) # prevent input while doing animation
	get_node("White").edit_set_rect(button_rect)
	get_node("Animator").play("flash")


func _on_Animator_finished():
	get_tree().get_root().set_disable_input(false) # prevent input while doing animation
	emit_signal("flash_finished")
