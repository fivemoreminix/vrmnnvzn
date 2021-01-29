extends Node2D

onready var SPEED = 75

export(NodePath) var RailPath   = "../../rail"
onready var rail                = get_node(RailPath)
onready var ship                = get_node(str(RailPath) + "/ship")

export(bool) var disabled = false
var scripted_move_to = null # global Vector2 or null

# State of the boss fight from 0 to 3
# 0 very beginning of fight
# 1 defeated first layer of armor
# 2 defeated second layer of armor
# 3 defeated engines (boss dies)
export(int, 3) var state = 0

var destroyed = false


func _ready():
	if state >= 1: on_armor_cover_destroyed()
	if state >= 2: on_engine_armor_destroyed()
	if state >= 3: on_engines_destroyed()
	
	set_process(true)


func _process(delta):
	if not disabled:
		if scripted_move_to != null:
			move_to(scripted_move_to, delta, 1.0)
		else:
			if state != 3:
				pass # Move and shit


func move_to(global_pos, delta, speed_mult):
	var dir = (global_pos - get_global_pos()).normalized()
	move(dir, delta, speed_mult)


func move(dir, delta, speed_mult):
	var pos = get_global_pos()
	
	pos += dir * SPEED * speed_mult * delta # Add movement
	
	set_global_pos(pos)


# When the player defeats the first layer of armor (signaled by the armor itself, which receives damages)
func on_armor_cover_destroyed():
	if state < 1: state = 1


# When the player destroys the second layer of armor covering the engines (signaled by armor)
func on_engine_armor_destroyed():
	if state < 2: state = 2


# When the player destroys both of the engines, which causes the boss to free fall to DOOM. (signaled by engines)
func on_engines_destroyed():
	if state < 3: state = 3


func _on_visibility_exit_screen():
	if state == 3: # Dead...
		queue_free()
