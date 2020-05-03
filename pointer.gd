extends Sprite

func _ready():
	set_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
#	_on_Pointer_visibility_changed()


#func _on_Pointer_visibility_changed():
#	if is_visible():
#		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
#	else:
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	set_global_pos(get_global_mouse_pos())
