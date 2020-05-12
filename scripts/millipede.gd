extends Node2D

const SEGMENT_TIME_OFFSET = 0.075
const SEGMENT_OFFSET = Vector2(0, -10)

export(NodePath) var path # Path2D
#export(float) var sine_magnitude = 15.0
var speed = 0.5
export(int) var body_segments = 10

var segment = preload("res://scenes/millipede_segment.tscn")
var segment_shape = preload("res://scenes/res/ycentipede_segment_shape.tres")

var destroyed = false
func destroy(): pass

onready var parts = []
var time = 0.0


func _ready():
	if path == null: printerr(get_name() + ": `path` is null, this node is not going to function properly.")
	
	# Initialize head
	get_node("head/AnimatedSprite").set_animation("head")
	parts.append(get_node("head"))
	
	# Create a reference-counted new shape resource for the body segments to use as their collision (fits the legs)
	var body_shape = get_node("head/Collider").get_shape().duplicate() # Duplicate resource
	body_shape.set_extents(Vector2(16, 8)) # Set the collision box wide enough to include legs on both sides of sprite
	
	# Create and initialize body and tail parts
	for i in range(body_segments+1):
		var n = segment.instance()
		
		if i < body_segments: # If we're not making the last segment ...
			n.get_node("AnimatedSprite").play("body")
			n.get_node("Collider").set_shape(body_shape) # Assign segment's shape to become the body shape resource
		else:
			n.get_node("AnimatedSprite").set_animation("tail")
		
		add_child(n)
		n.set_pos(SEGMENT_OFFSET * (i+1)) # Set Y position of segment
		
		move_child(n, 0) # Move segment to top of child tree (sorts Y)
		parts.append(n) # Add node to array for indexing later


func _process(delta):
	time += delta * speed # Update time variable
	
	# In the circumstance you may have "determined a bug" in the Millipede,
	# where it is not appearing/following the path, please make sure you position
	# the origin of the millipede at the origin of the path it will follow.
	# This is because it uses the path's local coordinates. Normal behaviour.
	var c = get_node(path).get_curve()
	for i in range(parts.size()): # For every part ...
		var p_time = max(0.0, time - SEGMENT_TIME_OFFSET*i)
		
		var new_pos = c.interpolatef(p_time)
		var motion = (new_pos - parts[i].get_pos()).normalized()
		parts[i].set_pos(new_pos)
		
		var sprite = parts[i].get_node("AnimatedSprite")
		if sprite.animation != "body":
			sprite.frame = get_sprite_idx_for_motion(motion)
		
		if motion.y >= -1.0 and motion.y < 0.0: # If we're going up...
			parts[i].set_z(i) # Z order = index
		else:
			parts[i].set_z(parts.size() - i - 1) # Z order = count - index - 1


# Only normalized motions!
func get_sprite_idx_for_motion(m):
#	0: (-.25 =..=  .25,   0 =..= 1) Down
#	1: (-.5   ..  -.25,   0 =..= 1) Lower left
#	2: (-.5  =..= -1,     0 =..= 1) Left
#	3: (-1    ..  -.25,  -1 =..  0) Upper left
#	4: (-.25 =..=  .25,  -1 =..  0) Up
#	5: ( .25  ..   1,    -1 =..  0) Upper right
#	6: ( .5  =..=  1,     0 =..= 1) Right
#	7: ( .25  ..   .5,    0 =..= 1) Lower right
	if m.y >= -1.0 and m.y < 0.0: # This is upward facing...
		if   m.x > -1.0 and m.x < -.25: return 3 # Upper left
		elif m.x >= -.25 and m.x <= .25: return 4 # Up
		else: return 5 # Upper right
	else: # This faces downward...
		if   m.x >= -.25 and m.x <= .25: return 0 # Down
		elif m.x > -.5 and m.x < -.25: return 1 # Lower left
		elif m.x < -.5 and m.x > -1.0: return 2 # Left
		elif m.x >= .5 and m.x <= 1.0: return 6 # Right
		else: return 7 # Lower right


# Begin following the path. This can be connected to a VisibilityNotifier in a level to trigger the millipede.
func begin():
	set_process(true)


func _on_VisibilityNotifier2D_exit_screen():
	get_node("QueueFreeTimer").start()


func _on_QueueFreeTimer_timeout():
	queue_free()
