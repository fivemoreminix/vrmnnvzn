extends Control

const RESOLUTION_FAIL_REGEX = "Resolution provided was not a valid input. A valid resolution would be widthxheight, for example: 800x600 is the default setting."
const RESOLUTION_NOT_MIN_SIZE = "The resolution provided was below the minimum recommended resolution size of 250x250. You can override this restriction in the global settings file."
const RESOLUTION_MIN_SIZE = Vector2(250, 250)

onready var fade = get_node("Fade")
var dirty = false # if values in this menu have changed at all

func _on_window_mode_value_changed(_):
	get_node("ResolutionOption").set_editable(get_node("WindowModeOption").get_text() == "Windowed")
#	var size = OS.get_screen_size(OS.get_current_screen())
#	get_node("ResolutionOption").set_text(str(size[0]) + "x" + str(size[1]))
	
	_on_value_changed(null)

func _on_value_changed(_):
	dirty = true
	get_node("Save").set_disabled(false)

func _ready():
	var err = GameData.load_global_data() # TODO: handle possible errors while loading global game data
	if err != 0 and err != 1:
		print("settings.gd: err != 0 while loading... ruh roh raggy, error: " + var2str(err)) # TODO: user-friendly dialogs for errors
		return
	# Set GUI components based on loaded global data
	get_node("SFXSlider").set_val(GameData.global_data.sfx_volume)
	get_node("MusicSlider").set_val(GameData.global_data.music_volume)
	get_node("VsyncCheck").set_pressed(GameData.global_data.vsync)
	
	get_node("WindowModeOption").set_text(GameData.global_data.window_mode)
	# Set what is toggled on the Window Mode dropdown menu
	var popup_menu = get_node("WindowModeOption").get_child(0)
	for i in range(get_node("WindowModeOption").get_item_count()):
		popup_menu.set_item_checked(i, GameData.global_data.window_mode == get_node("WindowModeOption").get_item_text(i))
	
	# Resolution
	if GameData.global_data.window_mode == "Windowed":
		get_node("ResolutionOption").set_text(GameData.global_data.resolution) # Use resolution size input by player
	else:
		get_node("ResolutionOption").set_text("800x600") # Use the default windowed game resolution
	get_node("ResolutionOption").set_editable(GameData.global_data.window_mode == "Windowed")
	
	get_node("Save").set_disabled(true) # Disable save button

func handle(func_name):
	if func_name == "save_changes":
		# validate ResolutionOption input
		var re = RegEx.new()
		re.compile("[0-9]+x[0-9]+")
		if re.find(get_node("ResolutionOption").get_text()) < 0:
			get_node("Dialog/Panel/Label").set_text(RESOLUTION_FAIL_REGEX)
			get_node("Dialog").show()
			return
		else:
			var xy = get_node("ResolutionOption").get_text().split("x", false)
			if int(xy[0]) < RESOLUTION_MIN_SIZE.x or int(xy[1]) < RESOLUTION_MIN_SIZE.y:
				get_node("Dialog/Panel/Label").set_text(RESOLUTION_NOT_MIN_SIZE)
				get_node("Dialog").show()
				return
	
	fade.begin_fade_out()
	fade.connect("fade_finished", self, func_name)

func go_back():
	get_tree().change_scene("res://main_menu.scn")

func save_changes():
	# write changes to GameData.global_data
	GameData.global_data.sfx_volume = get_node("SFXSlider").get_val()
	GameData.global_data.music_volume = get_node("MusicSlider").get_val()
	GameData.global_data.window_mode = get_node("WindowModeOption").get_text()
	if get_node("WindowModeOption").get_text() == "Windowed":
		GameData.global_data.resolution = get_node("ResolutionOption").get_text() # Use resolution size input by player
	else:
		var ssize = OS.get_screen_size(OS.get_current_screen())
		GameData.global_data.resolution = str(ssize.x) + "x" + str(ssize.y) # Use resolution size of current monitor
	GameData.global_data.vsync = get_node("VsyncCheck").is_pressed()
	print("settings.gd: saving GameData.global_data: " + var2str(GameData.global_data))
	# var err = GameData.save_global_data()
	var err = GameData.save_global_data()
	if err != 0:
		print("settings.gd: err != 0 while saving... ruh roh raggy, error: " + var2str(err)) # TODO: user-friendly dialogs for errors
		return
	
	GameData.refresh_video_settings() # Reload video
	
	get_tree().change_scene("res://main_menu.scn")
