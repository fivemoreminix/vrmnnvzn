tool
extends Node2D

signal rail_finished

const Y_MOTION = -50 # Local y position change in pixels each frame
const DIST_TO_BEGIN_LERP = 50
const INTERPOLATE_SPEED = 1

export var disabled = false # Used for cinematics or something

#export var max_x = 256 # Max x distance rail can travel from origin before stopping
export(int) var travel_y = 200 # The y distance the rail will travel before stopping (relative)
onready var starting_y = get_pos().y


func stop():
	set_process(false)


func _process(delta):
	if get_tree().is_editor_hint():
		update()
		return
	else:
		if disabled: return
		
		if get_pos().y <= -travel_y: # If the rail has travelled past the distance of travel_y ...
			emit_signal("rail_finished")
			set_process(false) # Block processing
		
		set_pos(get_pos() + Vector2(0, Y_MOTION) * delta)


func _ready():
	set_process(true)
	
	# Load player at checkpoints
	if not get_tree().is_editor_hint():
		if get_node("/root/GameData").data.current_section > 0: # We need to load at a checkpoint
			print("aligning with checkpoint: " + str(get_node("/root/GameData").data.current_section))
			for checkpoint in get_tree().get_nodes_in_group("Checkpoint"):
				if checkpoint.section_index == get_node("/root/GameData").data.current_section: # We found the checkpoint we need to be at ...
					# GameData updates
					get_node("/root/GameData").load_level_stats_from_section_snapshot(checkpoint.section_index)
					# triggered_section sets the section snapshot of level stats upon calling, that's why we
					# set the level stats from the section, prior. To prevent from collecting lots of kills,
					# and reloading the section, for example.
					get_node("/root/GameData").triggered_section(checkpoint.section_index)
					
					# Mechanical updates
					align_with_checkpoint(checkpoint)
					checkpoint.hide() # We don't want to see the checkpoint we're starting at...
					get_node("ship").input_disabled = false
					get_node("ship").add_effect("Phase-through", 1)
					break
		else: # Start from beginning of level
			# GameData updates
			get_node("/root/GameData").reset_level_stats()
			# we reset the level stats so that the section snapshot for start of level is entirely fresh.
			get_node("/root/GameData").triggered_section(0) # Section index 0 is the start of the level
			
			# Mechanical updates
			get_node("AnimationPlayer").play("FlyIn")


func _draw():
	if get_tree().is_editor_hint():
		draw_circle(Vector2(0, 0), 8, Color(1.0, 1.0, 1.0))
#		draw_circle(Vector2(5 - get_pos().x, 0), 6, Color(1.0, 0.0, 0.0))
		draw_circle(Vector2(0, -travel_y - get_pos().y), 6, Color(0.0, 1.0, 0.0))


func align_with_checkpoint(node):
	set_global_pos(node.get_global_pos() + Vector2(0, -192/2)) # Set camera centered with checkpoint
	get_node("ship").set_global_pos(node.get_respawn_global_pos()) # Set ship location to location by checkpoint
