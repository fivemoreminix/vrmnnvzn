
extends Area2D

# Member variables
const SPEED    = 100
const X_RANDOM = 10

export(NodePath) var TargetPath = "../../rail/ship"
var RailPath                    = "../../rail"
var target                      = null

var points    = 1
var direction = Vector2(0,0)
var destroyed = false
var reversed  = false


func _process(delta):
	translate(direction*SPEED*delta)
	if target.get_pos().x > get_pos().x-8 and target.get_pos().x < get_pos().x+8 and !reversed:
		get_node("sprite").play("flee")
		reversed = true


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
	direction = (target.get_pos() + get_node(RailPath).get_pos() - get_pos())
	var distance = direction.length()
	var targTimeToFuturePos = SPEED*distance
	var targFuturePos = target.get_pos() + target.motion + get_node(RailPath).get_pos() + get_node(RailPath).motion * targTimeToFuturePos
	direction = (targFuturePos - get_pos()).normalized()
	prints(" new direction: ", direction)
	
	set_process(true)


func _on_visibility_exit_screen():
	queue_free()
