extends Node2D

const SEGMENT_TIME_OFFSET = 5
const SEGMENT_OFFSET = Vector2(0, -10)

onready var sine_magnitude = 13.0 if GameData.data.difficulty == "Hard" else 10.0
onready var speed = 6 if GameData.data.difficulty == "Hard" else 4
export(int) var body_segments = 5

var segment = preload("res://scenes/centipede_segment.tscn")
var segment_shape = preload("res://scenes/res/ycentipede_segment_shape.tres")

var destroyed = false
var health = 4 # Number of times this enemy can take damage

func destroy():
	if not destroyed:
		health -= 1
		
		if health <= 0:
			queue_free()

onready var parts = []
var time = 0.0

func _ready():
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
	
	set_process(true)

func _process(delta):
	time += delta * speed # Update time variable
	for i in range(parts.size()): # For every part ...
		parts[i].set_pos(Vector2(sin(time + SEGMENT_TIME_OFFSET*i) * sine_magnitude, parts[i].get_pos().y))


func _on_VisibilityNotifier2D_exit_screen():
	get_node("QueueFreeTimer").start()


func _on_QueueFreeTimer_timeout():
	queue_free()
