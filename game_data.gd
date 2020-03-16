extends Node

# if these variables are null, then they have not yet been read from disk or created
var data = null
var global_data = null

func save_data(): # save game data to disk
	var f = File.new()
	f.open("user://VRMNNVZN.save", File.WRITE)
	f.store_string(data.to_json())
	f.close()

func load_data(): # load saved game data from disk
	var f = File.new()
	if f.file_exists("user://VRMNNVZN.save"): # if a save file exists ...
		f.open("user://VRMNNVZN.save", File.READ)
		data = {} # give a value so .parse_json doesn't cry...
		var err = data.parse_json(f.get_as_text())
		f.close()
		if err != OK:
			printerr("game_data.gd: failed to parse game data save file")
		return err
#	else: # data save file does NOT exist ...
#		data = { ### data defaults ###
#			current_level: 0,
#			highest_level_discovered: 0,
#			name: "", # player's name
#		}
#		print("game_data.gd: game data save file not found... creating one now")
#		return save_data() # make the file
	return ERR_FILE_NOT_FOUND

func save_global_data(): # save global data to disk
	var f = File.new()
	f.open("user://VRMNNVZN_global.save", File.WRITE)
	f.store_string(global_data.to_json())
	f.close()

# returns int: error type, so OK if succeeds, ERR_* otherwise
func load_global_data(): # load global data from disk
	var f = File.new()
	if f.file_exists("user://VRMNNVZN_global.save"): # if a save file exists ...
		f.open("user://VRMNNVZN_global.save", File.READ)
		global_data = {} # give a value so .parse_json doesn't cry...
		var err = global_data.parse_json(f.get_as_text())
		f.close()
		if err != OK:
			printerr("game_data.gd: failed to parse global save file")
		return err
	else: # global data save file does NOT exist ...
		global_data = { ### global_data defaults ###
			sfx_volume = 1.0,
			music_volume = 1.0,
		}
		print("game_data.gd: global save file not found... creating one now")
		return save_global_data() # make the file
