extends Area2D
# Member variables
const SPEED = 0
export(int) var bodySegments = 0
#var isHead = true
#var wasntHead = true
var trailing = null
onready var segment = preload("res://scenes/enemy1.tscn").instance()
onready var initPoint = get_global_pos()

var diverging = false
var wasDiverging = false
var divergeTime = 250
var divergeDir = null
var divergeStart = null

var destroyed=false
var screenTime = 0
var spawned = false


func _process(delta):
	var pos = get_pos()
	screenTime+=delta*2
	#if segment!=null and trailing!=null:
	#	get_node("sprite").set_animation("segment")
	#if segment==null and trailing!=null: 
	#	get_node("sprite").set_animation("tail")
	#if trailing==null: 
	#	get_node("sprite").set_animation("head")
	#else: 
	#	isHead = false
	
	#if isHead: 
	#	if wasntHead:
	#		wasntHead = false
	#		get_node("sprite").set_animation("head")
	#if !get_node("anim").is_playing():
	#	get_node("anim").play("default")
	#print(sin(screenTime))
	if !diverging:
		set_pos(Vector2(initPoint.x+(sin(screenTime)*18), pos.y+SPEED*delta))
	else:#
		translate(Vector2(delta*divergeDir/2, SPEED*delta))
		if OS.get_ticks_msec() - divergeStart >= divergeTime:
			diverging = false
	
	
	if !wasDiverging and diverging:
		wasDiverging = true
		if segment!=null:
			segment.diverging = true
			segment.divergeDir = divergeDir
			segment.divergeStart = OS.get_ticks_msec()
	
	if wasDiverging and !diverging:
		initPoint = pos
		wasDiverging = false
		if segment!=null:
			segment.initPoint = pos
			segment.diverging = false
	
	if segment==null and trailing==null:
		set_head()
	
	#else:  
	#	if trailing==null: return
	#	else:
	#		set_pos(Vector2(lerp(pos.x,trailing.get_global_pos().x,delta*8),trailing.get_global_pos().y-10))
	

#func _init():
#	if bodySegments > 0:
#		segment = preload("res://scenes/enemy1.tscn").instance()
#		segment.head = false
#		segment.trailing = self
#		segment.bodySegments = bodySegments-1
#		segment.set_pos(get_pos()-Vector2(0,16))
#		get_parent().add_child(segment)
#		print(segment)


func set_head():
	get_node("sprite").set_animation("head")
	if diverging == true:
		if bodySegments%2==0:
			divergeDir = -1
		else:
			divergeDir = 1
		divergeStart = OS.get_ticks_msec()


func set_segment(frame):
	if frame < 0:
		frame = 3
	get_node("sprite").set_animation("segment")
	get_node("sprite").set_frame(frame)


func set_tail():
	get_node("sprite").set_animation("tail")


func destroy():
	if (destroyed):
		return
	destroyed = true
	#get_node("anim").play("explode") 
	hide()
	set_process(false)
	if segment!=null:
		segment.diverging = true
		segment.set_head() 
		#get_parent().add_child(segment)
	if trailing!=null and trailing.trailing!=null:
		trailing.set_tail() 
	get_node("sfx").play("sound_explode")
	# Accumulate points
#	get_node("/root/game_state").points += 25


func _on_visibility_enter_screen():
	spawned = true
	#
	if bodySegments > 0:
		#segment =
		#segment.isHead       = false
		segment.trailing     = self
		segment.bodySegments = bodySegments-1
		segment.screenTime   = screenTime-(PI/10)
		segment.get_node("sprite").set_z(get_node("sprite").get_z()-1)
		segment.set_segment(get_node("sprite").get_frame()-1)
		segment.set_pos(Vector2(initPoint.x,get_global_pos().y)-Vector2(0,10))#Vector2(initPoint.x-sin(segment.screenTime),get_global_pos().y) 
		get_parent().add_child(segment)
		segment.initPoint    = initPoint
		#print(segment.get_name() + " spawned from " +self.get_name())
	elif bodySegments == 0:
		segment=null
		if trailing!=null:
			set_tail()
		else:
			set_head()
	set_process(true)
	#get_node("anim").play("zigzag")
	#get_node("anim").seek(randf()*2.0) # Make it start from any pos


func _on_visibility_exit_screen():
	#pass
	if spawned:
		if segment==null:
			queue_free()
			return
		else:
			segment.trailing = null 
		queue_free()
