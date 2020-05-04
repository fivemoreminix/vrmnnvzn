extends Control

signal finished


func start(level_name, difficulty_name, enemies_killed, blockers_cleared):
	get_node("LevelTitleLabel").set_text("\"" + level_name + "\"")
	get_node("Difficulty/Value").set_text(difficulty_name.to_upper())
	get_node("Enemies/Value").set_text(str(enemies_killed))
	get_node("Blockers/Value").set_text(str(blockers_cleared))
	
	get_node("AnimationPlayer").play("Anim")


func _on_AnimationPlayer_finished():
	emit_signal("finished")
