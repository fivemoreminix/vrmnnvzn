extends Node2D

# This value cannot be 0, 0 is reserved for start of level
export(int) var section_index = 1
export(bool) var easy_mode_only = true


func _ready():
	assert(section_index > 0)
	if easy_mode_only and GameData.data.difficulty != "Easy": hide()


func _on_Trigger_area_enter( area ):
	if is_visible(): # Checkpoints only enabled when visible
		if area.is_in_group("Player") and GameData.data.current_section < section_index:
			GameData.triggered_section(section_index)
			
			# Animate
			get_node("AnimationPlayer").play("Activated")
			get_node("SamplePlayer2D").play("checkpoint")


func get_respawn_global_pos():
	return get_node("RespawnPoint").get_global_pos()
