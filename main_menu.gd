extends Control

onready var fade = get_node("Fade")

func _ready():
	set_process(true)
	
	get_node("Continue").set_disabled(not File.new().file_exists("user://VRMNNVZN.save"))

func _process(delta):
	if not get_tree().get_root().is_input_disabled():
		if Input.is_action_pressed("ui_accept"):
			if File.new().file_exists("user://VRMNNVZN.save"): # use continue button
				get_node("Continue")._on_button_pressed()
			else: # use new game button
				get_node("NewGame")._on_button_pressed()

func handle(func_name):
	fade.begin_fade_out()
	print(fade.get_signal_connection_list("fade_finished"))
#	for f in fade.get_signal_connection_list("fade_finished"):
#		fade.disconnect("fade_finished", self, f["method"])
	fade.connect("fade_finished", self, func_name)

func new_game():
	get_tree().change_scene("res://new_game.tscn")

func continue_game():
	var f = File.new()
	f.open("user://VRMNNVZN.save", File.READ)
	var index = f.get_line()
	print("opened save file and got index = " + index)
	get_tree().change_scene("res://scenes/levels/lvl" + index + ".tscn")

func exit_game():
	get_tree().quit()

func _on_fade_finished():
	pass
