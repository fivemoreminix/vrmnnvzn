extends Control

onready var fade = get_node("Fade")
var dirty = false # if values in this menu have changed at all

func _on_value_changed(_):
	dirty = true
	get_node("Save").set_disabled(false)

func _ready():
	var err = GameData.load_global_data() # TODO: handle possible errors while loading global game data
	get_node("SFXSlider").set_val(GameData.global_data.sfx_volume)
	get_node("MusicSlider").set_val(GameData.global_data.music_volume)

func handle(func_name):
	if func_name == "save_changes": save_changes()
	else:
		fade.begin_fade_out()
		fade.connect("fade_finished", self, func_name)

func go_back():
	get_tree().change_scene("res://main_menu.scn")

func save_changes():
	# write changes to GameData.global_data
	GameData.global_data.sfx_volume = get_node("SFXSlider").get_val()
	GameData.global_data.music_volume = get_node("MusicSlider").get_val()
	# var err = GameData.save_global_data()
	var err = GameData.save_global_data()
	if err != null:
		printerr("settings.gd: err != null while saving... ruh roh raggy, error: " + str(err)) # TODO: user-friendly dialogs for errors
		return
	
	dirty = false
	get_node("Save").set_disabled(true)
