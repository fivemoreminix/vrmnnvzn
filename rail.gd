tool
extends Node2D

# Member variables
export var motion = Vector2(0, -50) # Direction of movement in pixels times delta each frame
export var max_x = 256 # Max x distance rail can travel from origin before stopping
export var max_y = 500 # Max y distance rail can travel from origin before stopping

func stop():
	set_process(false)

func _process(delta):
	if get_tree().is_editor_hint():
		update()
		return
	
	if get_pos().x >= max_x or get_pos().x <= -max_x or get_pos().y >= max_y or get_pos().y <= -max_y:
		return
	
	set_pos(get_pos() + delta*motion)

func _ready():
	set_process(true)

func _draw():
	if get_tree().is_editor_hint():
		draw_circle(Vector2(0, 0), 8, Color(1.0, 1.0, 1.0))
		draw_circle(Vector2(max_x - get_pos().x, 0), 6, Color(1.0, 0.0, 0.0))
		draw_circle(Vector2(0, -max_y - get_pos().y), 6, Color(0.0, 1.0, 0.0))
