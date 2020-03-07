
extends Area2D

# Member variables
const SPEED    = 60
const X_RANDOM = 10

#export(NodePath) var TargetPath = "../../rail/ship"
var RailPath                    = "../../rail"
var target                      = null

var points    = 1
export var speed_x = 30.0
var destroyed = false
var reversed  = false


func _process(delta):
	translate(Vector2(speed_x, 0)*delta)


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
	set_process(true)


func _on_visibility_exit_screen():
	if get_pos().x < 8:
		set_pos(Vector2(256,get_pos().y))
	elif get_pos().x > 256-8:
		set_pos(Vector2(0,get_pos().y))
