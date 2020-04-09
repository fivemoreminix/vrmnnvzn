extends Node2D

const SEGMENT_TIME_OFFSET = 0.1
const SEGMENT_OFFSET = Vector2(0, -10)

export(NodePath) var path # Path2D
#export(float) var sine_magnitude = 15.0
var speed = 0.5
export(int) var body_segments = 5

var segment = preload("res://scenes/millipede_segment.tscn")
var segment_shape = preload("res://scenes/res/ycentipede_segment_shape.tres")

var destroyed = false
func destroy(): pass

onready var parts = []
var time = 0.0


func _ready():
	if get_node(path) == null: printerr(get_name() + ": `path` is null, this node is not going to function properly.")
	
	
	# Initialize head
	get_node("head/AnimatedSprite").play("head")
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
			n.get_node("AnimatedSprite").play("tail")
		
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
		parts[i].set_pos(c.interpolatef(p_time))


# Begin following the path. This can be connected to a VisibilityNotifier in a level to trigger the millipede.
func begin():
	set_process(true)


func _on_VisibilityNotifier2D_exit_screen():
	get_node("QueueFreeTimer").start()
	print("Left screen")


func _on_QueueFreeTimer_timeout():
	queue_free()
