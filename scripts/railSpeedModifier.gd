extends VisibilityNotifier2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var Speed = 30

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_railSpeedModifier_enter_screen():
	get_node("/root/world/rail").set_speed(Speed)


func _on_railSpeedModifier_enter_viewport( viewport ):
	get_node("/root/world/rail").set_speed(Speed)

