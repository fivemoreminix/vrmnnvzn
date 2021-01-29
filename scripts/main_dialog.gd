extends Control

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		get_node("Cancel")._on_button_pressed()

func handle(func_name):
	get_node("../Fade").begin_fade_out()
	get_node("../Fade").connect("fade_finished", self, func_name)

func cancel():
	get_tree().change_scene("res://main_menu.scn")

func start():
	var diff
	if get_node("EasyCheck").is_pressed():
		diff = "Easy"
	elif get_node("NormalCheck").is_pressed():
		diff = "Normal"

	# See GameData for info about these
	GameData.data =
	{
		current_level = 0,
		current_section = 0,
		kills_this_level = 0,
		blockers_cleared_this_level = 0,
		highest_level_discovered = 0,
		name = get_node("Name").get_text().strip_edges(),
		difficulty = diff,
	}
	GameData.save_data() # write the new game data to disk

	get_tree().change_scene("res://scenes/levels/lvl0.tscn")


func _on_MediumCheck_pressed():
	get_node("EasyCheck").set_pressed(true)
	get_node("NormalCheck").set_pressed(false)


func _on_HardCheck_pressed():
	get_node("EasyCheck").set_pressed(false)
	get_node("NormalCheck").set_pressed(true)


func _on_Name_text_changed( text ):
	get_node("Start").set_disabled(text.strip_edges().empty())
