extends Control

signal finished # emitted when the user clicks the "Back" button

const RESOLUTION_FAIL_REGEX = "Resolution provided was not a valid input. A valid resolution would be widthxheight, for example: 800x600 is the default setting."
const RESOLUTION_NOT_MIN_SIZE = "The resolution provided was below the minimum recommended resolution size of 256x192. You can override this restriction in the global settings file."
const RESOLUTION_MIN_SIZE = Vector2(256, 192)

# Paths to nodes which store properties of global data
export(NodePath) var sfx_slider
export(NodePath) var music_slider
export(NodePath) var window_mode_selection
export(NodePath) var resolution_input
export(NodePath) var vsync_check
export(NodePath) var dialog_check
export(NodePath) var move_speed_slider


func _ready():
	var err = GameData.load_global_data()
	if err != 0 and err != 1:
		printerr("settings.gd: err != 0 while loading... error: " + var2str(err))
		return
		
	# Set GUI components based on loaded global data
	
	get_node(sfx_slider).set_val(GameData.global_data.sfx_volume)
	get_node(music_slider).set_val(GameData.global_data.music_volume)
	
	# Window Mode
	var win_mode_sel_node = get_node(window_mode_selection)
	win_mode_sel_node.set_text(GameData.global_data.window_mode)
	# Set what is toggled on the Window Mode dropdown menu
	var popup_menu = win_mode_sel_node.get_child(0)
	for i in range(win_mode_sel_node.get_item_count()):
		popup_menu.set_item_checked(i, GameData.global_data.window_mode == win_mode_sel_node.get_item_text(i))
	
	# Resolution
	var res_node = get_node(resolution_input)
	if GameData.global_data.window_mode == "Windowed":
		res_node.set_text(GameData.global_data.resolution) # Use resolution size input by player
	else:
		res_node.set_text("800x600") # Use the default windowed game resolution
	res_node.set_editable(GameData.global_data.window_mode == "Windowed")
	
	get_node(vsync_check).set_pressed(GameData.global_data.vsync)
	
	# Gameplay
	get_node(dialog_check).set_pressed(GameData.global_data.dialog_enabled)
	get_node(move_speed_slider).set_val(GameData.global_data.move_speed_factor)


# Write node values to GameData.global_data
# Afterwards, reload global data and tell GameData to refresh settings
func save_changes():
	# Audio
	GameData.global_data.sfx_volume = get_node(sfx_slider).get_val()
	GameData.global_data.music_volume = get_node(music_slider).get_val()
	
	# Display
	GameData.global_data.window_mode = get_node(window_mode_selection).get_text()
	if get_node(window_mode_selection).get_text() == "Windowed":
		GameData.global_data.resolution = get_node(resolution_input).get_text().strip_edges() # Use resolution size input by player
	else:
		var ssize = OS.get_screen_size(OS.get_current_screen())
		GameData.global_data.resolution = str(ssize.x) + "x" + str(ssize.y) # Use resolution size of current monitor
	GameData.global_data.vsync = get_node(vsync_check).is_pressed()
	
	# Gameplay
	GameData.global_data.dialog_enabled = get_node(dialog_check).is_pressed()
	GameData.global_data.move_speed_factor = get_node(move_speed_slider).get_val()
	
	# Save data
	print("settings.gd: saving GameData.global_data: " + var2str(GameData.global_data))
	# var err = GameData.save_global_data()
	var err = GameData.save_global_data()
	if err != 0:
		print("settings.gd: err != 0 while saving... error: " + var2str(err)) # TODO: user-friendly dialogs for errors
		return
	
	GameData.refresh_settings() # update audio/video


func handle(func_name):
	# validate ResolutionOption input
	var re = RegEx.new()
	re.compile("[0-9]+x[0-9]+")
	if re.find(get_node(resolution_input).get_text()) < 0:
		get_node("Dialog/Panel/Label").set_text(RESOLUTION_FAIL_REGEX)
		get_node("Dialog").show()
		return
	else:
		var xy = get_node(resolution_input).get_text().split("x", false)
		if int(xy[0]) < RESOLUTION_MIN_SIZE.x or int(xy[1]) < RESOLUTION_MIN_SIZE.y:
			get_node("Dialog/Panel/Label").set_text(RESOLUTION_NOT_MIN_SIZE)
			get_node("Dialog").show()
			return
	
#	fade.begin_fade_out()
#	fade.connect("fade_finished", self, func_name)
	call(func_name)


func go_back():
	save_changes()
	emit_signal("finished")


func _on_window_mode_value_changed(_):
	if get_node(window_mode_selection).get_text() == "Windowed":
		get_node(resolution_input).show()
	else:
		get_node(resolution_input).hide()


func _on_Music_value_changed( value ):
	AudioServer.set_stream_global_volume_scale(value)


func _on_SFX_value_changed( value ):
	AudioServer.set_fx_global_volume_scale(value)
