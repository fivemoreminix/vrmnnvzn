extends Sprite

func _ready():
	set_process(true)
	Input.set_mouse_mode(1)

func _process(delta):
	set_global_pos(get_global_mouse_pos())
