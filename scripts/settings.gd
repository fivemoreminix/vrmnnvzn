extends Control

onready var fade = get_node("Fade")
var dirty = false # if values in this menu have changed at all

func _on_value_changed(_):
	dirty = true
	get_node("Save").set_disabled(false)

func _ready():
	var err = GameData.load_global_data() # TODO: handle possible errors while loading global game data
	if err != 0:
		print("settings.gd: err != 0 while loading... ruh roh raggy, error: " + var2str(err)) # TODO: user-friendly dialogs for errors
		return
	# Set GUI components based on loaded global data
	get_node("SFXSlider").set_val(GameData.global_data.sfx_volume)
	get_node("MusicSlider").set_val(GameData.global_data.music_volume)
	get_node("WindowModeOption").set_text(GameData.global_data.window_mode)
	get_node("ResolutionOption").set_text(GameData.global_data.resolution)
	get_node("VsyncCheck").set_pressed(GameData.global_data.vsync)
	
	get_node("Save").set_disabled(true) # Disable save button

func handle(func_name):
	fade.begin_fade_out()
	fade.connect("fade_finished", self, func_name)

func go_back():
	get_tree().change_scene("res://main_menu.scn")

func save_changes():
	# write changes to GameData.global_data
	GameData.global_data.sfx_volume = get_node("SFXSlider").get_val()
	GameData.global_data.music_volume = get_node("MusicSlider").get_val()
	GameData.global_data.window_mode = get_node("WindowModeOption").get_text()
	GameData.global_data.resolution = get_node("ResolutionOption").get_text()
	GameData.global_data.vsync = get_node("VsyncCheck").is_pressed()
	print("settings.gd: saving GameData.global_data: " + var2str(GameData.global_data))
	# var err = GameData.save_global_data()
	var err = GameData.save_global_data()
	if err != 0:
		print("settings.gd: err != 0 while saving... ruh roh raggy, error: " + var2str(err)) # TODO: user-friendly dialogs for errors
		return
	
	get_tree().change_scene("res://main_menu.scn")
