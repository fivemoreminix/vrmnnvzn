extends Control

onready var fade = get_node("Fade")

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		go_back()

func handle(func_name):
	call(func_name)

func unlock_lvls():
	GameData.load_data()
	GameData.data.highest_level_discovered = 99
	GameData.save_data()

func go_back():
	fade.begin_fade_out()
	fade.connect("fade_finished", self, "handle_go_back")

func handle_go_back():
	get_tree().change_scene("res://scenes/settings.tscn")
