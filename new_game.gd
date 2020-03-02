extends Control

onready var fade = get_node("Fade")

func _ready():
	# these are hidden by default
	get_node("Warning").hide()
	get_node("MainDialog").hide()
	
	var f = File.new()
	if f.file_exists("user://VRMNNVZN.save"): # if a save file exists ...
		get_node("Warning").show()
	else:
		# TODO: difficulty selection
#		get_node("MainDialog").show()
		f.open("user://VRMNNVZN.save", File.WRITE)
		f.store_string("0") # store level number
		begin_fade_and_load_first_level()

func _on_Warning_user_made_decision(decision): # decision true if continue, false if no
	print("user made decision = " + str(decision))
	if decision == false:
		fade.begin_fade_out()
	else:
		get_node("Warning").hide()
		begin_fade_and_load_first_level()
#		get_node("MainDialog").show()

func begin_fade_and_load_first_level():
	fade.begin_fade_out()
	fade.connect("fade_finished", self, "_on_fade_finished_but_load_first_level")

func _on_fade_finished_but_load_first_level():
	get_tree().change_scene("res://scenes/levels/lvl0.tscn")

func _on_fade_finished():
	get_tree().change_scene("res://main_menu.tscn")
