extends Panel

const SCROLLING_SPEED = 135

onready var scrol_lbl = get_node("Text")
onready var scrol_lbl_default_x = scrol_lbl.get_pos().x

var _scrolling_text = false

func _ready():
#	scrolling_text("Woah, that's a big invasion ahead of you! Stay frosty.")
	pass

func _process(delta):
	if _scrolling_text:
		var cur_pos = scrol_lbl.get_pos()
		scrol_lbl.set_pos(Vector2(cur_pos.x-delta*SCROLLING_SPEED, cur_pos.y))
		if cur_pos.x + scrol_lbl.get_size().x < 0: # if out of frame ...
			scrol_lbl.set_pos(Vector2(scrol_lbl_default_x, cur_pos.y))
			scrol_lbl.hide()
			_scrolling_text = false

func scrolling_text(text):
	print("called scrolling_text")
	scrol_lbl.show()
	scrol_lbl.set_text(text)
	_scrolling_text = true
	set_process(true)
