
extends Area2D

# Member variables
const SPEED = 80

var motion = Vector2()
var dampen_speed = 10

var screen_size
var prev_shooting = false
var killed = false
onready var shipSprite = get_node("shipSprite")
onready var shots = [preload("res://scenes/shot.tscn"),preload("res://scenes/2shot.tscn"),preload("res://scenes/3shot.tscn"),preload("res://scenes/5shot.tscn")]
const maxShotLevel = 3
var banking = false
export(String, "None", "Speed", "FireRate", "Blah") var powerup = "None"

func _process(delta):
	if killed:
		if Input.is_action_pressed("ui_cancel"):
			_on_back_to_menu_pressed()
		return
	
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
	
	var pos = get_pos()
	
	# clamp motion
	motion = Vector2(clamp(motion.x, -1, 1), clamp(motion.y, -1, 1))
	# move ship
	pos += motion*delta*SPEED
	# lerp motion (motion dampening effect)
	motion = Vector2(lerp(motion.x, 0, delta*dampen_speed), lerp(motion.y, 0, delta*dampen_speed))
	
	if (pos.x < 0):
		pos.x = 0
	if (pos.x > screen_size.x):
		pos.x = screen_size.x
	if (pos.y < 0):
		pos.y = 0
	if (pos.y > screen_size.y):
		pos.y = screen_size.y
	
	set_pos(pos)
	
	if (shooting and not prev_shooting):
		# Just pressed
		var shot = shots[2 if powerup == "Shot" else 1].instance()
		get_node("anim").play("shoot")
		# Use the Position2D as reference
		shot.set_pos(get_node("shootfrom").get_global_pos())
		shot.set_rot(get_node("shootfrom").get_rot()) 
		# Put it two parents above, so it is not moved by us
		get_node("../..").add_child(shot)
		# Play sound
		get_node("sfx").play("shoot")
	
	prev_shooting = shooting
	
	# Update points counter
#	get_node("../hud/score_points").set_text(str(get_node("/root/game_state").points))


func _ready():
	screen_size = get_viewport().get_rect().size
	set_process(true)
	


func _hit_something():
	if killed:
		return
	killed = true
	get_node("shipSprite").hide()
	get_node("thruster").hide()
	get_node("explosion").show()
	get_node("explosion").play("default")
	get_node("sfx").play("sound_explode")
	get_node("../hud/game_over").show()
	get_node("/root/game_state").game_over()
	get_parent().stop()
#	set_process(false)


#func _input(ev):
#	print("pressed a key: " + str(ev))
#	if ev.type == InputEvent.ACTION and ev.is_action_pressed("ui_cancel"):
#		_on_back_to_menu_pressed()


func _on_ship_body_enter(body):
	_hit_something()


func _on_ship_area_enter(area):
	if (area.has_method("is_enemy") and area.is_enemy()):
		_hit_something()


func _on_back_to_menu_pressed():
	get_tree().change_scene("res://main_menu.scn")


func _on_PowerupTimer_timeout():
	powerup = "None"
