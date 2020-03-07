
extends Area2D

signal effect_added
signal effect_removed

# Member variables
const SPEED = 130

var motion = Vector2()
var dampen_speed = 10

var screen_size
#var prev_shooting = false
var can_shoot = true
var killed = false
onready var shipSprite = get_node("shipSprite")
onready var shots = [preload("res://scenes/shot.tscn"),preload("res://scenes/2shot.tscn"),preload("res://scenes/3shot.tscn"),preload("res://scenes/5shot.tscn")]
var banking = false

var active_effects = [] # a list of active powerups or detriments


func _ready():
	screen_size = get_viewport().get_rect().size
	set_process(true)


func _process(delta):
	if killed:
		if Input.is_action_pressed("ui_cancel"):
			_on_back_to_menu_pressed()
		return
	
	# decrease time remaining for all effects
	for e in active_effects:
		e[2] -= delta
		if e[2] <= 0:
			active_effects.erase(e) # remove the effect once duration has run out
			emit_signal("effect_removed", e)
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
	
	# Update points counter
#	get_node("../hud/score_points").set_text(str(get_node("/root/game_state").points))


func move(delta, motion):
	var pos = get_pos()
	
	# clamp motion
	#self.motion = Vector2(clamp(motion.x, -1, 1), clamp(motion.y, -1, 1))
	# move ship
	pos += motion*delta*SPEED
	# lerp motion (motion dampening effect)
	#self.motion = Vector2(lerp(self.motion.x, 0, delta*dampen_speed), lerp(self.motion.y, 0, delta*dampen_speed))
	
	pos.x = clamp(pos.x, 0, screen_size.x)
	pos.y = min(pos.y, 172)
	
	set_pos(pos)


func shoot():
	if can_shoot:
		# Just pressed
		var shot = shots[2 if has_effect(0, 2) else 1].instance()
		get_node("anim").play("shoot")
		# Use the Position2D as reference
		shot.set_pos(get_node("shootfrom").get_global_pos())
		shot.set_rot(get_node("shootfrom").get_rot()) 
		# Put it two parents above, so it is not moved by us
		get_node("../..").add_child(shot)
		# Play sound
		get_node("sfx").play("shoot")
		
		# reset condition
		can_shoot = false
		get_node("ShootTimer").start()


func kill():
	killed = true
	get_node("shipSprite").hide()
	get_node("thruster").hide()
	get_node("explosion").show()
	get_node("explosion").play("default")
	get_node("sfx").play("explode")
	get_node("../hud/game_over").show()
	get_node("/root/game_state").game_over()
	
 	#get_node("../hud/Pointer").show() # re-enable the mouse
	
	get_parent().stop()


func has_effect(type, effect):
	for e in active_effects:
		if e[0] == type and e[1] == effect: return true
	return false

#Add powerup and detriment effects to the player.
#
#type is of powerup.gd::Class, effect is of either powerup.gd::{Powerup, Detriment}.
func add_effect(type, effect, duration=5):
	# check if this effect is present ...
	for e in active_effects:
		if e[0] == type and e[1] == effect: active_effects.erase(e) # remove the effect from the list
		emit_signal("effect_removed", e)
	active_effects.append([type, effect, duration])
	emit_signal("effect_added", active_effects.size()-1) # returns index in array where the effect is present


func _hit_something():
	if killed: return
	else: kill()


func _on_ship_body_enter(body):
	_hit_something()


func _on_ship_area_enter(area):
#	if (area.has_method("is_enemy") and area.is_enemy()):
#		_hit_something()
	if area.is_in_group("Enemy") and not area.destroyed: # TODO: should not ever need to check if an enemy is dead
		_hit_something()


func _on_back_to_menu_pressed():
	get_tree().change_scene("res://main_menu.scn")


func _on_ShootTimer_timeout():
	can_shoot = true
