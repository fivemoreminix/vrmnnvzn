extends Node2D

const SEGMENT_TIME_OFFSET = 5
const SEGMENT_OFFSET = Vector2(0, -10)

onready var sine_magnitude = 10.0 if GameData.data.difficulty == "Normal" else 13.0
onready var speed = 6 if GameData.data.difficulty == "Normal" else 4
export(int) var body_segments = 5

var segment = preload("res://scenes/centipede_segment.tscn")
var segment_shape = preload("res://scenes/res/ycentipede_segment_shape.tres")

var destroyed = false
var health = 6 # Number of times this enemy can take damage

var flashing = false
var is_white = false

func destroy():
	if not destroyed:
		health -= 1
		
		if health <= 0:
			for i in range(parts.size()): # For every part ...
				parts[i].set_monitorable(false) # Disable collisions
				parts[i].get_node("AnimatedSprite").hide() # Hide segment sprites
				parts[i].get_node("explosion").show()
				parts[i].get_node("explosion").play("default")
				parts[i].get_node("legs_particles").set_emitting(true) # Emit particles
		else:
			flashing = true
			get_node("StunTimer").start()
			get_node("FlashTimer").start()

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
	if flashing:
		time += delta * speed * 0.5 # Move half speed
	else:
		time += delta * speed # Update time variable
	for i in range(parts.size()): # For every part ...
		parts[i].set_pos(Vector2(sin(time + SEGMENT_TIME_OFFSET*i) * sine_magnitude, parts[i].get_pos().y))


func _on_VisibilityNotifier2D_exit_screen():
	get_node("QueueFreeTimer").start()


func _on_QueueFreeTimer_timeout():
	queue_free()


func _on_StunTimer_timeout():
	flashing = false
	# Change all segment sprites back to default
	parts[0].get_node("AnimatedSprite").animation = "head"
	for i in range(1, parts.size()-1): # For every *body* part ...
		parts[i].get_node("AnimatedSprite").animation = "body"
	parts[parts.size()-1].get_node("AnimatedSprite").animation = "tail"
	
	get_node("FlashTimer").stop()
	is_white = false


func _on_FlashTimer_timeout():
	is_white = not is_white
	print(is_white)
	parts[0].get_node("AnimatedSprite").animation = "head_white" if is_white else "head"
	for i in range(1, parts.size()-1): # For every *body* part ...
		parts[i].get_node("AnimatedSprite").animation = "body_white" if is_white else "body"
	parts[parts.size()-1].get_node("AnimatedSprite").animation = "tail_white" if is_white else "tail"
#	get_node("sprite").play("white" if is_white else "default")
