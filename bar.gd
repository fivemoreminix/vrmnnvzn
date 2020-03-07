extends Panel

const SCROLLING_SPEED = 135

onready var scrol_lbl = get_node("Text")
onready var scrol_lbl_default_x = scrol_lbl.get_pos().x

var _scrolling_text = false


func _process(delta):
	if _scrolling_text:
		var cur_pos = scrol_lbl.get_pos()
		scrol_lbl.set_pos(Vector2(cur_pos.x-delta*SCROLLING_SPEED, cur_pos.y))
		if cur_pos.x + scrol_lbl.get_size().x < 0: # if out of frame ...
			scrol_lbl.set_pos(Vector2(scrol_lbl_default_x, cur_pos.y))
			scrol_lbl.hide()
			_scrolling_text = false


func scrolling_text(text):
	scrol_lbl.show()
	scrol_lbl.set_text(text)
	_scrolling_text = true
	set_process(true)

#export(String, "Fast shooting", "Phase-through", "Triple-shot") var powerup_type = "Fast shooting"
#export(String, "Tough enemies", "Less health", "Wow, accurate!", "Homing enemies") var detriment_type
func _on_ship_effect_added(index, name):
	var n = TextureFrame.new()
	
	if name == "Triple-shot": n.set_texture(preload("res://assets/sprites/powerup/powerup_triple_shot.png"))
	elif name == "Fast shooting": n.set_texture(preload("res://assets/sprites/powerup/powerup_fast_shooting.png"))
	elif name == "Phase-through": n.set_texture(preload("res://assets/sprites/powerup/powerup_phase_through.png"))
	else:
		printerr("bar.gd: Powerup name not identified: " + name)
		n.set_texture(preload("res://assets/sprites/powerup/powerup0.png"))
	get_node("Box").add_child(n)


func _on_ship_effect_removed(index, name):
	get_node("Box").get_child(index).queue_free()
