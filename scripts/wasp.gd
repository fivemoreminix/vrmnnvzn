extends Area2D

const STUN_DIR = Vector2(1, -1) # Direction wasp moves while stunned

# Member variables
onready var SPEED = 60 if GameData.data.difficulty == "Normal" else 75

export(NodePath) var RailPath   = "../../rail"
onready var rail                = get_node(RailPath)
onready var ship                = get_node(RailPath + "/ship")

export(bool) var disabled = false
#export(bool) var play_alert_sound_when_visible = false

# state
enum State {
	Following, # Wasp will follow player on the left or right sides of the screen, before hovering
	Hovering,  # Wasp hovers in front of player, firing down at them
	Fleeing,   # Wasp was hit, so now it is fleeing to the right of the screen
}
var state = State.Hovering

# health
var health = 4 # Number of times this enemy can take damage
var destroyed = false

# stun
var flashing = false
var is_white = false

func _process(delta):
	if not disabled:
		if flashing:
			global_translate(STUN_DIR*SPEED*delta*0.5)
		else:
			if state == State.Following: follow(delta)
			elif state == State.Hovering: hover(delta)
			else: flee(delta)


func follow(delta):
	pass


func hover(delta):
	var rail_pos = rail.get_global_pos()
	var ship_pos = ship.get_global_pos()
	var target_pos = Vector2(ship_pos.x, rail_pos.y + 50)
	
	var dir = (target_pos - get_global_pos()).normalized()
	
	move(dir, delta)


func flee(delta):
	pass


func move(dir, delta):
	set_global_pos(get_pos() + dir * SPEED)


func destroy():
	if not destroyed:
		health -= 1
		
		get_node("sfx").play("bee_hit")
		
		if health <= 0:
			destroyed = true
			get_node("sprite").hide()
			get_node("explosion").show()
			get_node("explosion").play("default")
			get_node("wings0").set_emitting(true)
			get_node("wings1").set_emitting(true)
			get_node("legs0").set_emitting(true)
			get_node("legs1").set_emitting(true)
			
			set_process(false)
			call_deferred("set_monitorable", false) # Disable the collisions on this Bee
#			set_monitorable(false) # This won't work because we can't prevent monitoring while monitoring...
			get_node("sfx").play("sound_explode")
		else:
			flashing = true
			get_node("StunTimer").start()
			get_node("FlashTimer").start()


func _on_visibility_enter_screen():
	set_process(true) # begin moving


func _on_visibility_exit_screen():
	queue_free()


func _on_asteroid_area_enter( area ): # "asteroid" comes from this project's origins
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
