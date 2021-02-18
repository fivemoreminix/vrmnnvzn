extends Control

var accessible_icon = preload("res://assets/images/selectable.png")
var levels = []


func _ready():
	GameData.load_data()
	
	levels = GameData.get_levels()
	
	for i in range(levels.size()):
		var accessible
		if GameData.data != null: # If an active save game exists
			accessible = i <= int(GameData.data.highest_level_discovered)
		else: # No game save exists
			accessible = false
		get_node("ItemList").add_item(str(i + 1) + ": " + levels[i][0], accessible_icon if accessible else null, accessible)
	
	get_node("ItemList").select(0)
#	get_node("ItemList").grab_focus()


func handle(func_name):
	get_node("Fade").begin_fade_out()
	get_node("Fade").connect("fade_finished", self, func_name)


func cancel():
	get_tree().change_scene("res://scenes/main_menu.scn")


func start():
	var selected_level_idx = levels[get_node("ItemList").get_selected_items()[0]][1]
	GameData.load_data()
	GameData.data.current_level = selected_level_idx
	GameData.data.current_section = 0
	GameData.data.deaths = 0
	GameData.save_data()
	printerr(selected_level_idx)
	get_tree().change_scene("res://scenes/levels/lvl" + selected_level_idx + ".tscn")


func _on_ItemList_item_activated( _ ):
	handle("start")


func _on_ItemList_draw():
	# Prevent clicking start button when nothing is selected
	get_node("Start").set_disabled(get_node("ItemList").get_selected_items().size() < 1)
