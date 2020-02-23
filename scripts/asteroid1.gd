
extends Area2D

# Member variables
const SPEED    = 60
const X_RANDOM = 10

export(NodePath) var TargetPath = "../../rail/ship"
var RailPath                    = "../../rail"
var target                      = null

var points    = 1
var speed_x   = 0.0
var speed_y   = 0.0
var destroyed = false
var reversed  = false


func _process(delta):
	translate(Vector2(speed_x, SPEED)*delta)
	if target.get_pos().x > get_pos().x-8 and target.get_pos().x < get_pos().x+8 and !reversed:
		#print("reversed")
		get_node("sprite").play("flee")
		reversed = true
		speed_x = -speed_x*2.5


func _ready():
	target = get_node(TargetPath)
	#speed_x = rand_range(-X_RANDOM, X_RANDOM)


func destroy():
	if (!destroyed):
		destroyed = true
		get_node("sprite").hide()
		get_node("explosion").show()
		get_node("explosion").play("default")
		#get_node("anim").play("explode")
		set_process(false)
		get_node("sfx").play("sound_explode")
		# Accumulate points
		get_node("/root/game_state").points += 10
	else:
		if !get_node("explosion").is_playing():
			queue_free()
		return


func is_enemy():
	return not destroyed


func _on_visibility_enter_screen():
	var run = target.get_pos().x - get_pos().x
	#print(run)
	var rise = target.get_pos().y - get_pos().y #(get_pos().y-get_node(RailPath).get_pos().y) -
	#print(rise)
	speed_x = run/(rise/SPEED)
	speed_y = rise/(run/SPEED)
	#print(speed_x)
	set_process(true)
	# Make it spin!
	#get_node("anim").play("spin")


func _on_visibility_exit_screen():
	queue_free()
