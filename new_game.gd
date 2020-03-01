extends Control

func _ready():
	var f = File.new()
	if f.file_exists("user://VRMNNVZN.save"): # if a save file exists ...
		get_node("Warning").show()
	else:
		get_node("MainDialog").show()


func _on_Warning_user_made_decision(decision): # decision true if continue, false if no
	print("user made decision = " + str(decision))
	if decision == false:
		get_tree().change_scene("res://main_menu.tscn")
	else:
		get_node("Warning").hide()
		get_node("MainDialog").show()
