extends Control

onready var fade = get_node("Fade")
onready var pointer = get_node("pointer")

func _ready():
	set_process(true)
	
	get_node("Continue").set_disabled(not File.new().file_exists("user://VRMNNVZN.save"))
	
	#set the mouse cursor sprite:
	Input.set_mouse_mode(1)

func _process(delta):
	pointer.set_pos(get_local_mouse_pos())
	if not get_tree().get_root().is_input_disabled():
		if Input.is_action_pressed("ui_accept"):
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
