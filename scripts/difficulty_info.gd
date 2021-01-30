extends Control

var current_difficulty = "Easy"
var first_time_play = true
export var infoEasy = "on Easy, enemies are a bit slower,\n and you can shoot one bullet."
export var infoNormal = "on Normal, enemies are a bit faster, \n you can shoot one bullet. \n and every other thing is just normal ..."




func set_info_txt():
	if first_time_play:
		if current_difficulty == "Easy":
			get_node("Popup/Panel/Info").set_text(infoEasy)
		elif current_difficulty == "Normal":
			get_node("Popup/Panel/Info").set_text(infoNormal)
		show()



func _on_EasyCheck_pressed():
	current_difficulty = "Easy"
	set_info_txt()

func _on_NormalCheck_pressed():
	current_difficulty = "Normal"
	set_info_txt()


func _on_Ok_pressed():
	hide()


func _on_delay_show_timeout():
	set_info_txt()
