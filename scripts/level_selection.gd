extends Control

var levels = []


func _ready():
	GameData.load_data()
	
	levels = GameData.get_levels()
	
	for i in range(levels.size()):
		get_node("ItemList").add_item(levels[i][0], null, i <= int(GameData.data.highest_level_discovered))
	
	get_node("ItemList").select(0)
#	get_node("ItemList").grab_focus()


func handle(func_name):
	get_node("Fade").begin_fade_out()
	get_node("Fade").connect("fade_finished", self, func_name)


func cancel():
	get_tree().change_scene("res://main_menu.scn")


func start():
	var selected_level_idx = levels[get_node("ItemList").get_selected_items()[0]][1]
	GameData.load_data()
	GameData.data.current_level = selected_level_idx
	GameData.save_data()
	get_tree().change_scene("res://scenes/levels/lvl" + selected_level_idx + ".tscn")


func _on_ItemList_item_activated( _ ):
	handle("start")


func _on_ItemList_draw():
	# Prevent clicking start button when nothing is selected
	get_node("Start").set_disabled(get_node("ItemList").get_selected_items().size() < 1)
