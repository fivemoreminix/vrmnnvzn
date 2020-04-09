extends Control

var levels = []


func _ready():
	GameData.load_data()
	
	update_levels_from_csv()
	
	for i in range(levels.size()):
		get_node("ItemList").add_item(levels[i][0], null, i <= GameData.data.current_level)
	
	get_node("ItemList").select(0)
#	get_node("ItemList").grab_focus()


func update_levels_from_csv():
	var f = File.new()
	f.open("res://levels.csv", File.READ)
	while !f.eof_reached():
		var csv = f.get_csv_line()
		levels.append(csv)
	f.close()


func handle(func_name):
	get_node("Fade").begin_fade_out()
	get_node("Fade").connect("fade_finished", self, func_name)


func cancel():
	get_tree().change_scene("res://main_menu.scn")


func start():
	get_tree().change_scene(levels[get_node("ItemList").get_selected_items()[0]][1])


func _on_ItemList_item_activated( _ ):
	handle("start")


func _on_ItemList_draw():
	# Prevent clicking start button when nothing is selected
	get_node("Start").set_disabled(get_node("ItemList").get_selected_items().size() < 1)
