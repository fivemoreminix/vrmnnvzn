
extends Area2D

# Member variables
const SPEED    = 50

export(NodePath) var TargetPath = "../../rail/ship"
var RailPath                    = "../../rail"
var target                      = null

var direction = Vector2(0,0)
var health = 2 # Number of times this enemy can take damage
var destroyed = false

var target_pos = Vector2(0, 0)

var flashing = false
var is_white = false

func _process(delta):
	if flashing:
		global_translate(-direction*SPEED*delta*0.5)
	else:
		global_translate(direction*SPEED*delta)


func _ready():
	target = get_node(TargetPath)


func destroy():
	if not destroyed:
		health -= 1
		
		if health <= 0:
			destroyed = true
			get_node("sprite").hide()
			get_node("explosion").show()
			get_node("explosion").play("default")
			get_node("wings0").set_emitting(true)
			get_node("wings1").set_emitting(true)
			get_node("head").set_emitting(true)
			get_node("legs0").set_emitting(true)
			get_node("legs1").set_emitting(true)
			
			set_process(false)
			set_monitorable(false) # Disable the collisions on this Bee
			get_node("sfx").play("sound_explode")
		else:
			flashing = true
			get_node("StunTimer").start()
			get_node("FlashTimer").start()


func _on_visibility_enter_screen():
	var rail_speed = target.get_parent().motion
	var player_speed = target.SPEED # + target.motion.y ?
	var player_pos = target.get_global_pos()
	var distance = (player_pos - get_global_pos()).length() # distance: us from player
#	print(var2str(distance))
	
	# What offset from the player's current position when we get there?
	var predict = Vector2(0, -player_speed) * get_process_delta_time() * (distance * (1/SPEED))
#	print(var2str(predict))
	
	target_pos = player_pos + predict
#	print(var2str(target_pos))
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


func _on_StunTimer_timeout():
	flashing = false
	get_node("sprite").play("default")
	get_node("FlashTimer").stop()
	is_white = false


func _on_FlashTimer_timeout():
	is_white = not is_white
	get_node("sprite").play("white" if is_white else "default")
