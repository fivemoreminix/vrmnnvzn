
extends Area2D

#signal effect_added
#signal effect_removed

# Member variables
const SPEED = 130
onready var DEFAULT_SHOOT_WAIT_TIME = get_node("ShootTimer").get_wait_time() # basically a constant

var motion = Vector2()
var dampen_speed = 10

var screen_size
#var prev_shooting = false
var can_shoot = true
var killed = false
onready var shipSprite = get_node("shipSprite")
onready var shots = [preload("res://scenes/shot.tscn"),preload("res://scenes/2shot.tscn"),preload("res://scenes/3shot.tscn")]
var banking = false

var active_effects = [] # a list of active powerups or detriments [type of effect, effect name, duration as a float]


func _ready():
	screen_size = get_viewport().get_rect().size
	set_process(true)


func _process(delta):
	if Input.is_action_pressed("pause"):
		get_node("../hud/Pause").set_menu_pause()
		get_node("../hud/Pause").popup(true)
	
	# decrease time remaining for all effects
	for e in active_effects:
		e[1] -= delta
		if e[1] <= 0:
			active_effects.erase(e) # remove the effect once duration has run out
#			emit_signal("effect_removed", active_effects.size(), e[1])
			# Some effects may have "after-effects":
			if e[0] == "Phase-through": stop_blinking()
	
	
	motion = Vector2(0,0)
	if Input.is_action_pressed("move_up"):
		motion += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		motion += Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		motion += Vector2(-1, 0)
		if !banking:
			shipSprite.play("bankLeft")
			banking = true
	if Input.is_action_pressed("move_right"):
		motion += Vector2(1, 0)
		if !banking:
			shipSprite.play("bankRight")
			banking = true
	if (!Input.is_action_pressed("move_right") or !Input.is_action_pressed("move_left")) or (Input.is_action_pressed("move_right") and Input.is_action_pressed("move_left")):
		shipSprite.set_animation("default")
		banking = false
	var shooting = Input.is_action_pressed("shoot")
	
	move(delta, motion)
	
	if shooting: shoot()


func move(delta, motion):
	var pos = get_pos()
	
	# move ship
	pos += motion*delta*SPEED
	
	pos.x = clamp(pos.x, 0, screen_size.x)
	pos.y = min(pos.y, 168)
	
	set_pos(pos)

func shoot():
	if can_shoot:
		# Just pressed
		var shot = shots[2 if has_effect("Triple-shot") else 1].instance()
		get_node("anim").play("shoot")
		# Use the Position2D as reference
		shot.set_pos(get_node("shootfrom").get_global_pos())
		shot.set_rot(get_node("shootfrom").get_rot()) 
		# Put it two parents above, so it is not moved by us
		get_node("../..").add_child(shot)
		# Play sound
		get_node("sfx").play("shoot")
		
		if has_effect("Shoot diag"):
			for side in ["Left", "Right"]:
				var shot = shots[0].instance()
				shot.set_pos(get_node("shootfromDiag" + side).get_global_pos())
				shot.set_rot(get_node("shootfromDiag" + side).get_rot()) 
				get_node("../..").add_child(shot)
		
		# reset condition
		can_shoot = false
		var t = get_node("ShootTimer")
		if has_effect("Fast shooting"): t.set_wait_time(0.2)
		else: t.set_wait_time(DEFAULT_SHOOT_WAIT_TIME)
		t.start()


func kill():
	killed = true
	get_node("shipSprite").hide()
	get_node("thruster").hide()
	get_node("explosion").show()
	get_node("explosion").play("default")
	get_node("sfx").play("explode")
	
	get_node("../hud/Pause").set_menu_player_died()
	get_node("../hud/Pause").popup(true)
	
	set_process(false) # Keep player from being controllable after death
	get_parent().stop() # Stop the rail from moving


func has_effect(name):
	for e in active_effects:
		if e[0] == name: return true
	return false

#Add powerup effects to the player.
#
# See: powerup.gd for the effect names
func add_effect(name, duration=5):
	# check if this effect is present ...
	for e in active_effects:
		if e[0] == name:
			active_effects.erase(e) # remove the effect from the list
	active_effects.append([name, duration])
	
	# Play sound
	get_node("sfx").play("powerup_get")
	
	# Some effects have actions that only need to start upon receiving the effect:
	if name == "Phase-through": begin_blinking()

func _hit_something():
	if killed: return
	else: kill()


func _on_ship_body_enter(body):
	_hit_something()


func _on_ship_area_enter(area):
	print("hitting something")
#	if area.is_in_group("Enemy") and not area.destroyed and not has_effect("Phase-through"): # TODO: should not ever need to check if an enemy is dead
	if area.is_in_group("Enemy") and not has_effect("Phase-through"):
		_hit_something()


func _on_back_to_menu_pressed():
	get_tree().change_scene("res://main_menu.scn")


func _on_ShootTimer_timeout():
	can_shoot = true

### BLINKING ###

func begin_blinking():
	get_node("BlinkTimer").start()

func stop_blinking():
	get_node("BlinkTimer").stop()
	show()

func _on_BlinkTimer_timeout():
	if is_visible(): hide()
	else: show()

### END BLINKING ###
