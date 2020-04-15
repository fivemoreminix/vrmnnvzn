extends Node2D

# This value cannot be 0, 0 is reserved for start of level
export(int) var section_index = 1


func _ready():
	assert(section_index > 0)


func _on_Trigger_area_enter( area ):
	if area.is_in_group("Player") and GameData.data.current_section < section_index:
		GameData.triggered_section(section_index)
		
		# Animate
		get_node("AnimationPlayer").play("Activated")


func get_respawn_global_pos():
	return get_node("RespawnPoint").get_global_pos()
