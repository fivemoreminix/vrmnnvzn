extends Area2D

export var PowerupType = "shot"
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Powerup_area_enter( area ):
	if area.get_name() == "ship":
		pass # replace with function body
