extends Control

signal option_selected # passes an int
signal option_canceled

export var options = []

func _ready():
	pass

func add_option(v):
	options.append(v)

func update_options():
	# Populate VBoxContainer with options
	var c = get_node("Panel/ItemList")
	c.clear()
	for opt in options:
		print(opt)
		c.add_item(str(opt), null, true)

func _on_ItemList_item_activated( index ):
	emit_signal("option_selected", index)

func _on_ItemList_draw():
	# Prevent clicking start button when nothing is selected
	get_node("Panel/Accept").set_disabled(get_node("Panel/ItemList").get_selected_items().size() < 1)
