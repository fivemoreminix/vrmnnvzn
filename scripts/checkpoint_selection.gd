extends Control

signal option_selected # passes an int
signal option_canceled

export var options = []

func _ready():
	pass

# Notice: *Items should be added in order of ascending position. Therefore: start of level appended first*
func add_option(v):
	options += [v]

func update_options():
	# Populate VBoxContainer with options
	var c = get_node("Panel/ItemList")
	c.clear()
	for i in range(options.size()-1, -1, -1): # Iterate items in reverse
		print(options[i])
		c.add_item(str(options[i]), null, true)

func _on_ItemList_item_activated( index ):
	emit_signal("option_selected", options.size() - 1 - index) # Reverse index (because items are reversed)

func _on_ItemList_draw():
	# Prevent clicking start button when nothing is selected
	get_node("Panel/Accept").set_disabled(get_node("Panel/ItemList").get_selected_items().size() < 1)
