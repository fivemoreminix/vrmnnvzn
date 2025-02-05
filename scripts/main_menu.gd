extends Control

export(AudioStream) var music_stream

onready var fade = get_node("Fade")

func _ready():
	print("Data dir: \"" + OS.get_data_dir() + "\"")
	
	set_process(true)
	
	get_node("Continue").set_disabled(not File.new().file_exists("user://VRMNNVZN.save"))
	Music.set_ensure_playing(music_stream)


func _process(delta):
	if not get_tree().get_root().is_input_disabled():
		if Input.is_action_pressed("ui_accept"):
			if File.new().file_exists("user://VRMNNVZN.save"): # use continue button
				get_node("Continue")._on_button_pressed()
			else: # use new game button
				get_node("NewGame")._on_button_pressed()


func handle(func_name):
	if func_name == "continue_game":
		Music.fade_out()
	elif func_name == "settings":
		settings()
		return
	
	fade.begin_fade_out()
	fade.connect("fade_finished", self, func_name)


func new_game():
	get_tree().change_scene("res://scenes/new_game.tscn")


func continue_game():
	var err = GameData.load_data()
	if err != 0:
		print("main_menu.gd: error loading game data: " + var2str(err))
		return
	
	get_tree().change_scene("res://scenes/levels/lvl" + str(GameData.data.current_level) + ".tscn")


func levels():
	get_tree().change_scene("res://scenes/level_selection.tscn")


func exit_game():
	get_tree().quit()


func settings():
	get_node("SettingsScene").show()


func info():
	get_tree().change_scene("res://scenes/information.tscn")


func _on_SettingsScene_finished():
	get_node("SettingsScene").hide()
