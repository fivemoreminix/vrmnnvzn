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
		get_node("MainDialog").show()
#		begin_fade_and_load_first_level()

func _on_Warning_user_made_decision(decision): # decision true if continue, false if no
	if decision == false:
		fade.connect("fade_finished", self, "_on_fade_finished")
		fade.begin_fade_out()
	else:
		get_node("Warning").hide()
		get_node("MainDialog").show()

func _on_fade_finished():
	get_tree().change_scene("res://scenes/main_menu.scn")
