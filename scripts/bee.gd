
extends Area2D

var powerup = preload("res://scenes/powerup.tscn")

# Member variables
onready var SPEED = 75 if GameData.data.difficulty == "Normal" else 60
var powerup_drop_chance = 20 if GameData.data.difficulty == "Normal" else 45

export(NodePath) var TargetPath = "../../rail/ship"
var RailPath                    = "../../rail"
var target                      = null

export(bool) var disabled = false
export(bool) var play_alert_sound_when_visible = false

var direction = Vector2(0,0)
var health = 2 # Number of times this enemy can take damage
var destroyed = false

var target_pos = Vector2(0, 0)

var flashing = false
var is_white = false

func _process(delta):
	if not disabled:
		if flashing:
			global_translate(-direction*SPEED*delta*0.5)
		else:
			global_translate(direction*SPEED*delta)


func _ready():
	target = get_node(TargetPath)


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
			
			# chance to spawn a random powerup on death
			if randi() % 100 < powerup_drop_chance:
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
#	if play_alert_sound_when_visible:
#		get_node("sfx").play("alert")
	
	var rail_speed = Vector2(0, target.get_parent().Y_MOTION)
	var player_speed = target.SPEED
	var player_pos = target.get_global_pos()
	var distance = (player_pos - get_global_pos()).length() # distance: us from player
	
	# What offset from the player's current position when we get there?
	var predict = Vector2(0, -player_speed) * get_process_delta_time() * (distance * (1.0/SPEED))
	
	target_pos = player_pos + predict
	direction = (target_pos - get_global_pos()).normalized()
	
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
