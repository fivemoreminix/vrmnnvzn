extends Area2D

const STUN_DIR = Vector2(1, -1) # Direction wasp moves while stunned

var powerup = preload("res://scenes/powerup.tscn")

# Onready
onready var SPEED = 75 if GameData.data.difficulty == "Normal" else 60
onready var enemy_shot = preload("res://scenes/enemy_shot.tscn")

export(NodePath) var RailPath   = "../../rail"
onready var rail                = get_node(RailPath)
onready var ship                = get_node(str(RailPath) + "/ship")

export(bool) var writing = false
export(bool) var disabled = false
var scripted_move_to = null # global Vector2 or null

# shooting
var can_shoot = true

# state
enum State {
	Following, # Wasp will follow player on the left or right sides of the screen when hurt, before hovering
	Hovering,  # Wasp hovers in front of player, firing down at them
	Fleeing,   # Wasp was hit, so now it is fleeing to the right of the screen and returns with one more health
}
var state = State.Hovering

# following values
export var follow_right = true # if true, wasp follows on right side of player, otherwise left side
var follow_y_height = 100

# fleeing values
var out_of_screen = true

# health
var health = 4 # Number of times this enemy can take damage
var destroyed = false

# stun
var flashing = false
var is_white = false

func set_writing(v):
	writing = v
	if writing:
		get_node("sprite").play("writing")
	else:
		get_node("sprite").play("default")

func _ready():
	set_writing(writing)

func _process(delta):
	if not disabled and not writing:
		if scripted_move_to != null: # We're going somewhere specific
			move_to(scripted_move_to, delta, 1.0)
		else: # normal AI
			if flashing:
				global_translate(STUN_DIR*SPEED*delta*0.5)
			else:
				if state == State.Following: follow(delta)
				elif state == State.Hovering: hover(delta)
				else: flee(delta)


func shoot():
	if can_shoot:
		var shot = enemy_shot.instance()
		shot.set_pos(get_node("shootfrom").get_global_pos())
		shot.set_rot(get_node("shootfrom").get_global_rot()) 
		get_parent().add_child(shot)
		
		can_shoot = false
		get_node("ShootTimer").start()


func follow(delta):
	var rail_pos = rail.get_global_pos()
	var ship_pos = ship.get_global_pos()
	var view_size = get_viewport().get_rect().size
	var target_pos = Vector2(view_size.width - 10 if follow_right else 10, rail_pos.y + follow_y_height)
	
	move_to(target_pos, delta, 1.0)


func hover(delta):
	var rail_pos = rail.get_global_pos()
	var ship_pos = ship.get_global_pos()
	var target_pos = Vector2(ship_pos.x, rail_pos.y + 25)
	
	move_to(target_pos, delta, 1.0)
	shoot()


func flee(delta):
	var rail_pos = rail.get_global_pos()
	var ship_pos = ship.get_global_pos()
	var target_pos = Vector2(256 + 25, rail_pos.y)
	
	move_to(target_pos, delta, 1.5)


func move_to(global_pos, delta, speed_mult):
	var dir = (global_pos - get_global_pos()).normalized()
	move(dir, delta, speed_mult)


func move(dir, delta, speed_mult):
	var pos = get_global_pos()
	
	pos += dir * SPEED * speed_mult * delta # Add movement
	
	set_global_pos(pos)


func begin_flee():
	# set state to fleeing
	state = State.Fleeing
	# begin flee timer
	get_node("FleeTimer").start()
	# reset and stop follow timer
	get_node("FollowTimer").stop()


func begin_follow():
	# set state to following
	state = State.Following
	# set following variables to random values
	follow_right = true if randi() % 2 == 1 else false
	follow_y_height = rand_range(25, 128-25)


func destroy():
	if not destroyed:
		health -= 1
		
		get_node("sfx").play("bee_hit")
		
		if health == 1: begin_flee()
		
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
			
			# Spawn a random powerup on death
			var p = powerup.instance()
			p.set_global_pos(get_global_pos())
			get_parent().add_child(p)
			
			return true
		else:
			flashing = true
			get_node("StunTimer").start()
			get_node("FlashTimer").start()
	return false


func _on_visibility_enter_screen():
	set_process(true) # begin moving


func _on_visibility_exit_screen():
	if state != State.Fleeing:
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


func _on_FollowTimer_timeout():
	if state != State.Fleeing:
		if state == State.Hovering:
			begin_follow()
		else: state = State.Hovering


func _on_FleeTimer_timeout():
	state = State.Hovering
	health += 1
	get_node("FollowTimer").start() # We reset the follow timer after fleeing


func _on_ShootTimer_timeout():
	can_shoot = true
