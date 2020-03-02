extends Node

signal fade_finished # for function callback

const FADE_TIME = 1.0
onready var black_flash = get_node("BlackFlash")
var fade_progress = 0.0

func _process(delta):
	if fade_progress >= FADE_TIME:
		emit_signal("fade_finished")
		set_process(false)
	else:
		fade_progress += delta
		black_flash.set_modulate(Color(0.0, 0.0, 0.0, fade_progress))

func begin_fade_out():
	black_flash.show()
	black_flash.set_modulate(Color(0.0, 0.0, 0.0, 0.0))
	set_process(true)
