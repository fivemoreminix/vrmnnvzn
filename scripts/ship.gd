extends Area2D

signal enemy_killed(enemy)


# Constants variables
const SPEED = 180 # maximum movement speed / target speed ; move_speed is actual speed
const INTERP_SPEED = 15 # rate of interpolation

onready var DEFAULT_SHOOT_WAIT_TIME = 0.3 if GameData.data.difficulty == "Normal" else 0.2

var move_speed = 0.0 # actual speed to be applied to movement
var movement = Vector2(0, 0) # actual movement applied to position

var screen_size
export var input_disabled = false
var override_move_target = null # Vector2, location to move to
var override_move_target_time = 0.0
var can_shoot = true
var killed = false
onready var shipSprite = get_node("shipSprite")
onready var shots = [preload("res://scenes/shot.tscn"),preload("res://scenes/2shot.tscn"),preload("res://scenes/3shot.tscn")]

var active_effects = [] # a list of active powerups or detriments [effect name, duration as a float]

onready var last_mouse_pos = get_viewport().get_mouse_pos()

func _ready():
	screen_size = get_viewport().get_rect().size
	set_process(true)


func _process(delta):
	if Input.is_action_pressed("pause"):
		get_node("../hud/Pause").set_menu_pause()
		get_node("../hud/Pause").popup(true, false)
	
	# decrease time remaining for all effects
	for e in active_effects:
		e[1] -= delta
		if e[1] <= 0:
			active_effects.erase(e) # remove the effect once duration has run out
#			emit_signal("effect_removed", active_effects.size(), e[1])
			# Some effects may have "after-effects":
			if e[0] == "Phase-through": stop_blinking()
	
	if override_move_target != null:
		override_move_target_time += delta
		var cpos = get_global_pos()
		cpos = cpos.linear_interpolate(override_move_target, override_move_target_time)
		set_global_pos(cpos)
	else:
		if not input_disabled:
			var motion = Vector2(0,0)
			if Input.is_action_pressed("move_up"):
				motion += Vector2(0, -0.7)
			if Input.is_action_pressed("move_down"):
				motion += Vector2(0, 1)
			if Input.is_action_pressed("move_left"):
				motion += Vector2(-1, 0)
			if Input.is_action_pressed("move_right"):
				motion += Vector2(1, 0)
			
			move(delta, motion.normalized())
			
			var shooting = Input.is_action_pressed("shoot")
			if shooting: shoot()


func move(delta, motion):
	var pos = get_pos()
	
	# apply interpolation
	var target_speed = motion.length() * SPEED # assumes motion is normalized
	move_speed = lerp(move_speed, target_speed, INTERP_SPEED * delta)
	print(move_speed)
	
	movement = movement.linear_interpolate(motion * move_speed * delta, INTERP_SPEED * delta)
	
	# move ship
	pos += movement
#	pos += motion * move_speed * delta
	
	pos.x = clamp(pos.x, 0, screen_size.x)
	pos.y = clamp(pos.y, 12, 175)
	
	set_pos(pos)

func shoot():
	if can_shoot:
		# Just pressed
		var shot = shots[2 if has_effect("Triple-shot") else 1 if has_effect("Double-shot") else 0].instance()
		get_node("anim").play("shoot")
		# Use the Position2D as reference
		shot.set_pos(get_node("shootfrom").get_global_pos())
		shot.set_rot(get_node("shootfrom").get_rot()) 
		
		shot.connect("enemy_destroyed", self, "on_enemy_destroyed")
		
		# Put it two parents above, so it is not moved by us
		get_node("../..").add_child(shot)
		# Play sound
		get_node("sfx").play("shoot")
		
		if has_effect("Shoot diag"):
			for side in ["Left", "Right"]:
				var shot = shots[0].instance()
				shot.set_pos(get_node("shootfromDiag" + side).get_global_pos())
				shot.set_rot(get_node("shootfromDiag" + side).get_rot())
				
				shot.connect("enemy_destroyed", self, "on_enemy_destroyed")
				
				get_node("../..").add_child(shot)
		
		# reset condition
		can_shoot = false
		var t = get_node("ShootTimer")
		if has_effect("Fast shooting"): t.set_wait_time(DEFAULT_SHOOT_WAIT_TIME - 0.1)
		else: t.set_wait_time(DEFAULT_SHOOT_WAIT_TIME)
		t.start()


func kill():
	if not killed:
		killed = true
		call_deferred("set_monitorable", false) # Keep other enemies from dying on our invisible collider

		get_node("shipSprite").hide()
		get_node("thruster").hide()
		get_node("explosion").show()
		get_node("explosion").play("default")
		get_node("sfx").play("explode")
		
		get_node("../hud/Pause").popup(true, true) # Show pause menu dialog
		get_node("../hud/Pause").handle("restart") # Show checkpoint selection menu
		
		set_process(false) # Keep player from being controllable after death
		get_parent().stop() # Stop the rail from moving
		
		GameData.data.deaths += 1


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


func on_enemy_destroyed(enemy):
	if enemy.is_in_group("Bee"):
		GameData.data.level_stats.bees_killed += 1
	elif enemy.is_in_group("Centipede"):
		GameData.data.level_stats.centipedes_killed += 1
	elif enemy.is_in_group("Wasp"):
		GameData.data.level_stats.wasps_killed += 1
		
	emit_signal("enemy_killed", enemy)


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
