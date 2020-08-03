extends Node2D

export var level_name = "A Rookie at Hell's Gates"
export(NodePath) var rail_path = "rail"
export(NodePath) var end_of_level_gui_path = "EndOfLevelGUI"
export(NodePath) var fade_path = "rail/hud/Fade"

onready var rail = get_node(rail_path)
onready var end_of_level_gui = get_node(end_of_level_gui_path)
onready var fade = get_node(fade_path)


func _ready():
#	get_node("Music").play()
	pass


func _on_LevelFinishTrigger_level_finished():
	rail.get_node("ship").input_disabled = true # Ship may no longer move...


func _on_rail_rail_finished():
	end_of_level_gui.start(level_name, GameData.data.difficulty, GameData.data.kills_this_level, GameData.data.blockers_cleared_this_level)
	rail.get_node("ship").override_move_target = end_of_level_gui.get_node("ShipPosition").get_global_pos()


func _on_EndOfLevelGUI_finished():
	# TODO: fade music out
	# fade screen to black
	fade.begin_fade_out()
	fade.connect("fade_finished", self, "_on_Fade_fade_finished")


func _on_Fade_fade_finished():
#	get_node("Sfx").play("level_finish")
	# scroll text saying "Level finished!"
#	get_node("rail/hud/BottomBar").scrolling_text("Level finished!")
	GameData.finished_level()
