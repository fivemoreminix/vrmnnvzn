extends Control

signal finished


func start(level_name):
	get_node("LevelTitleLabel").set_text("\"" + level_name + "\"")
	get_node("Difficulty/Value").set_text(GameData.data.difficulty.to_upper())
	
	var lvl_stats = GameData.data.level_stats
	get_node("Bees/Value").set_text(str(lvl_stats.bees_killed))
	get_node("Centipedes/Value").set_text(str(lvl_stats.centipedes_killed))
	get_node("Wasps/Value").set_text(str(lvl_stats.wasps_killed))
	get_node("Deaths/Value").set_text(str(GameData.data.deaths))
	
	get_node("AnimationPlayer").play("Anim")


func _on_AnimationPlayer_finished():
	emit_signal("finished")
