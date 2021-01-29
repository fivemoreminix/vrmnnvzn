extends Control

var current_difficulty = "Easy"
var first_time_play = true
export var infoEasy = "on Easy, enemies are a bit slower,\n and you can shoot two bullets."
export var infoNormal = "on Normal, enemies are a bit faster, \n you can shoot one bullet. \n and every other thing is just normal ..."

func _ready():
	load_difficulty()
	set_info_txt()




func load_difficulty():
	var f = File.new()
	if f.file_exists("user://VRMNNVZN.save"):
		f.open("user://VRMNNVZN.save", File.READ)
		var data = {}
		var err = data.parse_json(f.get_as_text())
		f.close()
		if err != OK:
			print("difficulty: failed to parse game data save file")
			return
		current_difficulty = String(data.difficulty)
		if int(data.current_section) > 0:
			first_time_play = false # so that it doesn't popup when you have already played the level (when you have allready a section saved)

func set_info_txt():
	if first_time_play:
		if current_difficulty == "Easy":
			get_node("Popup/Info").set_text(infoEasy)
		elif current_difficulty == "Normal":
			get_node("Popup/Info").set_text(infoNormal)
		get_node("Popup").popup()


func _on_infoTime_timeout():

	get_node("Popup").hide()
