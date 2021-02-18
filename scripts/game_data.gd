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
		
		### Make numbered values whole integers ###
		# Level data
		data.current_level = int(data.current_level)
		data.current_section = int(data.current_section)
		data.highest_level_discovered = int(data.highest_level_discovered)
		
		# Level stats
		data.level_stats.bees_killed = int(data.level_stats.bees_killed)
		data.level_stats.centipedes_killed = int(data.level_stats.centipedes_killed)
		data.level_stats.wasps_killed = int(data.level_stats.wasps_killed)
		data.deaths = int(data.deaths)
		
		return 0
		# ** To add data, edit in NewGame node's MainDialog child script **
		# ** Bottom of this script has handlers for end of level changes **
#	else: # data save file does NOT exist ...
#		data = { ### data defaults ###
#			current_level: 0,
#			current_section: 0,
#			kills_this_level: 0,
#			blockers_cleared_this_level: 0,
#			highest_level_discovered: 0,
#			name: "", # player's name
#			difficulty: "Normal",
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
		
		refresh_audio_settings()
		refresh_video_settings()
		
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

func refresh_audio_settings():
	# Set SFX volume
	global_data.sfx_volume = clamp(global_data.sfx_volume, 0.0, 1.0)
	print(global_data.sfx_volume)
	AudioServer.set_fx_global_volume_scale(global_data.sfx_volume)
	# Set music volume
	global_data.music_volume = clamp(global_data.music_volume, 0.0, 1.0)
	AudioServer.set_stream_global_volume_scale(global_data.music_volume)

func refresh_video_settings():
	print("game_data.gd: Refreshing video settings: " + var2str(global_data.resolution))
	
	var xy = global_data.resolution.split("x", false)
	if xy.size() != 2:
		print("resolution is not in a valid form: " + var2str(global_data.resolution))
		print("go to " + OS.get_data_dir() + "/VRMNNVZN_global.save" + ", and set \"resolution\": \"800x600\" to reset it, or delete the file and a new one will be made.")
		get_tree().quit()
		return 2
	var x = int(xy[0])
	var y = int(xy[1])
	
	var fullscreen = global_data.window_mode == "Fullscreen" or global_data.window_mode == "Borderless"
	if fullscreen:
		var size = OS.get_screen_size(OS.get_current_screen())
		x = size.x
		y = size.y # Make sure screen size matches before updating
	OS.set_window_fullscreen(fullscreen)
	OS.set_borderless_window(global_data.window_mode == "Borderless")
	OS.set_window_size(Vector2(x, y))
	OS.set_use_vsync(global_data.vsync)
#	var ssize = OS.get_screen_size(OS.get_current_screen())
#	OS.set_window_position(Vector2(ssize.x/2-x/2, ssize.y/2-y/2))

func _enter_tree():
	load_global_data() # Load global data and refresh video settings upon game load (this code is a singleton)


### GAME-WIDE HELPER FUNCTIONS ###
func get_levels(): # returns Array in form of [[level name],[level index]], ...
	var f = File.new()
	f.open("res://levels.csv", File.READ)
	var levels = []
	while !f.eof_reached():
		var csv = f.get_csv_line()
		levels.append(csv)
	f.close()
	return levels

func get_levels_count():
	return get_levels().size()


func reset_level_stats():
	data.level_stats = {       # A snapshot of level_stats at each section ([0] is start of level)
		bees_killed = 0,       # Active "this level" statistics. Reset on the start of each level,
		centipedes_killed = 0, # or set to section_stats[sect. idx] when loading from checkpoint
		wasps_killed = 0,
	}


# Yes, this is a long function name. But at least you know what it does.
func load_level_stats_from_section_snapshot(section_index):
	data.level_stats = data.section_stats[section_index]
	print("Loading level stats from section snapshot: " + str(data.level_stats))
	print("(All section indices: " + str(data.section_stats) + ")")


# triggered_section is called at the start of a level, and on any checkpoints. Start of level has index = 0.
func triggered_section(index):
	print("Calling triggered_section with: " + str(data.level_stats))
	data.current_section = index
	assert(data.section_stats.size() >= index - 1)
	
	var level_stats_duplicate = {}
	clone_dict(data.level_stats, level_stats_duplicate)
	
	data.section_stats.insert(index, level_stats_duplicate) # Take snapshot of level stats at section index
	data.section_stats.resize(index + 1) # Erase any items following `index`
	save_data()
	print("Leaving triggered_section with: " + str(data.level_stats))


func clone_dict(source, target):
	for key in source:
		target[key] = source[key]


# Using saved data about the current level, we will update save game data, save the game, then load the next level.
func finished_level():
	data.current_section = 0
	data.deaths = 0
	data.current_level = int(data.current_level)
	if data.current_level < get_levels_count()-1:
		data.highest_level_discovered = max(data.highest_level_discovered, data.current_level + 1)
		data.current_level += 1
		save_data()
		get_tree().change_scene("res://scenes/levels/lvl" + str(data.current_level) + ".tscn")
	else: # Roll credits
		save_data()
		get_tree().change_scene("res://scenes/information.tscn")
