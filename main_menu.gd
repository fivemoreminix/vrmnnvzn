extends Control


func _ready():
#	get_node("score").set_text("HIGH SCORE: " + str(get_node("/root/game_state").max_points))
	set_process(true)


func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		_on_play_pressed()


func _on_play_pressed():
#	get_node("/root/game_state").points = 0
	get_tree().change_scene("res://scenes/levels/lvl0.tscn")
