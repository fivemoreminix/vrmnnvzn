extends Control

const SCROLLING_SPEED = 125

export var messages_hidden = false # Enable to hide the message bar and prevent sounds

onready var scrol_lbl = get_node("Panel/Text")
onready var scrol_lbl_default_x = scrol_lbl.get_pos().x


func _process(delta):
	var cur_pos = scrol_lbl.get_pos()
	scrol_lbl.set_pos(Vector2(cur_pos.x-delta*SCROLLING_SPEED, cur_pos.y))
	if cur_pos.x + scrol_lbl.get_size().x < get_viewport_rect().size.width: # If the text fits in the box now
		get_node("AnimationPlayer").play("Hide")
		set_process(false)


func message(text):
	if not messages_hidden and GameData.global_data.dialog_enabled:
		get_node("AnimationPlayer").play("Show")
		get_node("../../MessageSoundPlayer").play("bloop")
		get_node("Timer").start()
		scrol_lbl.set_text(text)
		set_process(false)


func _on_Timer_timeout():
	set_process(true) # Player is ready for the text to begin scrolling ;)
