
extends Area2D

# Member variables
const SPEED    = 50

export(NodePath) var TargetPath = "../../rail/ship"
var RailPath                    = "../../rail"
var target                      = null

var direction = Vector2(0,0)
var destroyed = false

var target_pos = Vector2(0, 0)


func _process(delta):
	global_translate(direction*SPEED*delta)


func _ready():
	target = get_node(TargetPath)


func destroy():
	if (!destroyed):
		destroyed = true
		get_node("sprite").hide()
		get_node("explosion").show()
		get_node("explosion").play("default")
		#get_node("anim").play("explode")
		set_process(false)
		get_node("sfx").play("sound_explode")
	else:
		if !get_node("explosion").is_playing():
			queue_free()
		return


func _on_visibility_enter_screen():
	var rail_speed = target.get_parent().motion
	var player_speed = target.motion * target.SPEED
	var player_pos = target.get_global_pos()
	var distance = (player_pos - get_global_pos()).length() # distance: us from player
	target_pos = player_pos + rail_speed + player_speed * get_process_delta_time() * distance
	direction = (target_pos - get_global_pos()).normalized()
#	print("player pos: " + var2str(player_pos))
#	print("future player pos: " + var2str(target_pos))
#	print(get_name() + "'s direction: " + var2str(direction))
	
	set_process(true) # begin moving


func _on_visibility_exit_screen():
	queue_free()


func _on_asteroid_area_enter( area ):
	if area.is_in_group("Player"):
		destroy()
