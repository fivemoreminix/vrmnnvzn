extends Node

# if these variables are null, then they have not yet been read from disk or created
var data = null
var global_data = null

# returns int: error type, so 0 = OK loaded fine, 2 = SHIT EXPLODED, FILE WONT SAVE
func save_data(): # save game data to disk
	var f = File.new()
	var err = f.open("user://VRMNNVZN.save", File.WRITE)
	if err != OK: return 2
	f.store_string(data.to_json())
	f.close()
	return 0

# returns int: error type, so 0 = OK loaded fine, 1 = could not find an existing file, 2 = SHIT EXPLODED WHILE READING SAVE FILE
func load_data(): # load saved game data from disk
	var f = File.new()
	if f.file_exists("user://VRMNNVZN.save"): # if a save file exists ...
		f.open("user://VRMNNVZN.save", File.READ)
		data = {} # give a value so .parse_json doesn't cry...
		var err = data.parse_json(f.get_as_text())
		f.close()
		if err != OK:
			print("game_data.gd: failed to parse game data save file")
			return 2
		return 0
#	else: # data save file does NOT exist ...
#		data = { ### data defaults ###
#			current_level: 0,
#			highest_level_discovered: 0,
#			name: "", # player's name
#		}
#		print("game_data.gd: game data save file not found... creating one now")
#		return save_data() # make the file
	return 1

# returns int: error type, so 0 = OK loaded fine, 2 = SHIT EXPLODED, FILE WONT SAVE
func save_global_data(): # save global data to disk
	var f = File.new()
	var err = f.open("user://VRMNNVZN_global.save", File.WRITE)
	if err != OK: return 2
	f.store_string(global_data.to_json())
	f.close()
	return 0

# returns int: error type, so 0 = OK loaded fine, 1 = had to create the file, 2 = SHIT EXPLODED, FILE WONT READ
func load_global_data(): # load global data from disk
	var f = File.new()
	if f.file_exists("user://VRMNNVZN_global.save"): # if a save file exists ...
		f.open("user://VRMNNVZN_global.save", File.READ)
		global_data = {} # give a value so .parse_json doesn't cry...
		var err = global_data.parse_json(f.get_as_text())
		f.close()
		if err != OK:
			print("game_data.gd: failed to parse global save file")
			return 2
		
		# for the purposes of making this software stable, we will load game resolution and window type immediately
		# upon reading the global data file
		var xy = global_data.resolution.split("x", false)
		if xy.size() != 2:
			print("resolution is not in a valid form: " + var2str(global_data.resolution))
			print("go to " + OS.get_data_dir() + "/VRMNNVZN_global.save" + ", and set \"resolution\": \"800x600\" to reset it, or delete the file and a new one will be made.")
			get_tree().quit()
			return 2
		
		print("game_data.gd: Initializing video settings: " + var2str(global_data.resolution))
		OS.set_window_fullscreen(global_data.window_mode == "Fullscreen" or global_data.window_mode == "Borderless")
		OS.set_borderless_window(global_data.window_mode == "Borderless")
		OS.set_window_size(Vector2(xy[0], xy[1]))
		OS.set_use_vsync(global_data.vsync)
		
		return 0
	else: # global data save file does NOT exist ...
		global_data = { ### global_data defaults ###
			sfx_volume = 1.0,
			music_volume = 1.0,
			window_mode = "Windowed", # note: this property must be typed in title case
			resolution = "800x600",
			vsync = true,
		}
		print("game_data.gd: global save file not found... creating one now")
		save_global_data()
		return 1 # make the file
