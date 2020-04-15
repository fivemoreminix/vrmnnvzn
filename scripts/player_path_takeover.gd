extends Area2D

var player = null
var motion = null


func _on_PlayerPathTakeover_area_enter( area ):
	if area.is_in_group("Player"):
		player = area
		player.input_disabled = true
		motion = (get_node("TargetPos").get_global_pos() - player.get_global_pos()).normalized()
		set_process(true)


func _process(delta):
	assert(player != null) # set_process(true) is called when these vars are set
	assert(motion != null)
	player.move(delta, motion)
