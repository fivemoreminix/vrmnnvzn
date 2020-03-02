extends Control

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
		get_tree().change_scene("res://scenes/levels/lvl0.tscn")

func _on_Warning_user_made_decision(decision): # decision true if continue, false if no
	print("user made decision = " + str(decision))
	if decision == false:
		get_tree().change_scene("res://main_menu.tscn")
	else:
		get_node("Warning").hide()
		get_tree().change_scene("res://scenes/levels/lvl0.tscn")
#		get_node("MainDialog").show()
