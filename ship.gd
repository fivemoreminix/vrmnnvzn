extends Area2D

signal enemy_destroyed


# Member variables
const SPEED = 110
onready var DEFAULT_SHOOT_WAIT_TIME = get_node("ShootTimer").get_wait_time() # basically a constant

var motion = Vector2()

var screen_size
var input_disabled = false
var override_move_target = null # Vector2, location to move to
var override_move_target_time = 0.0
var can_shoot = true
var killed = false
onready var shipSprite = get_node("shipSprite")
onready var shots = [preload("res://scenes/shot.tscn"),preload("res://scenes/2shot.tscn"),preload("res://scenes/3shot.tscn")]

var active_effects = [] # a list of active powerups or detriments [type of effect, effect name, duration as a float]

onready var default_shot_idx = 1 if GameData.data.difficulty != "Normal" else 0

onready var last_mouse_pos = get_viewport().get_mouse_pos()

func _ready():
	screen_size = get_viewport().get_rect().size
	set_process(true)
#	set_process_input(true)


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
	
	if override_move_target != null:
#		motion = (override_move_target - get_global_pos()).normalized()
#		move(delta, motion)
		override_move_target_time += delta
		var cpos = get_global_pos()
		cpos = cpos.linear_interpolate(override_move_target, override_move_target_time)
		set_global_pos(cpos)
	else:
		if not input_disabled:
			motion = Vector2(0,0)
			if Input.is_action_pressed("move_up"):
				motion += Vector2(0, -1)
			if Input.is_action_pressed("move_down"):
				motion += Vector2(0, 1.5)
			if Input.is_action_pressed("move_left"):
				motion += Vector2(-1, 0)
			if Input.is_action_pressed("move_right"):
				motion += Vector2(1, 0)
			
			move(delta, motion)
			
			var shooting = Input.is_action_pressed("shoot")
			if shooting: shoot()


# Experimental mouse support
#func _input(event):
#	if event.type == InputEvent.MOUSE_MOTION:
#		print(var2str(event.relative_pos))
#		move(get_process_delta_time(), event.relative_pos)


func move(delta, motion):
	var pos = get_pos()
	
	# move ship
	pos += motion*delta*SPEED
	
	pos.x = clamp(pos.x, 0, screen_size.x)
	pos.y = min(pos.y, 175)
	
	# Make y value discrete to prevent (most) stuttering
	pos.y = int(pos.y)
	
	set_pos(pos)

func shoot():
	if can_shoot:
		# Just pressed
		var shot = shots[2 if has_effect("Triple-shot") else default_shot_idx].instance()
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
		if has_effect("Fast shooting"): t.set_wait_time(0.2)
		else: t.set_wait_time(DEFAULT_SHOOT_WAIT_TIME)
		t.start()


func kill():
	if not killed:
		killed = true
		call_deferred("set_monitorable", false) # Keep other enemies from dying on our invisible collider
#		set_monitorable(false) # This won't work because we can't prevent monitoring while monitoring...
		get_node("shipSprite").hide()
		get_node("thruster").hide()
		get_node("explosion").show()
		get_node("explosion").play("default")
		get_node("sfx").play("explode")
		
		get_node("../hud/Pause").handle("restart")
		
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

func on_enemy_destroyed():
	emit_signal("enemy_destroyed")

### END BLINKING ###
