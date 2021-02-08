extends Control

onready var fade = get_node("Fade")

func _ready():
	print("Data dir: \"" + OS.get_data_dir() + "\"")
	
	set_process(true)
	
	get_node("Continue").set_disabled(not File.new().file_exists("user://VRMNNVZN.save"))
	GameData.load_global_data() # To initialize video settings and get the global data into memory

func _process(delta):
	if not get_tree().get_root().is_input_disabled():
		if Input.is_action_pressed("ui_accept"):
			if File.new().file_exists("user://VRMNNVZN.save"): # use continue button
				get_node("Continue")._on_button_pressed()
			else: # use new game button
				get_node("NewGame")._on_button_pressed()

func handle(func_name):
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
	get_tree().change_scene("res://scenes/settings.tscn")

func info():
	get_tree().change_scene("res://scenes/information.tscn")
