extends Panel

onready var fade = get_node("../Fade")
var player_is_dead = false

func _ready():
	set_process(true)

func _process(delta):
	if (Input.is_action_pressed("ui_cancel") or Input.is_action_pressed("pause")) and not \
	   get_node("Resume").is_disabled()                                           and not \
	   get_node("AnimationPlayer").is_playing()                                   and not \
	   player_is_dead: resume()

func set_menu_player_died():
	get_node("Label").show()
	get_node("Label1").hide()
	get_node("Resume").set_disabled(true)
	get_node("Restart").grab_focus() # Restart is preferred option

func set_menu_pause():
	get_tree().set_pause(true)
	get_node("Label").hide()
	get_node("Label1").show()
	get_node("Resume").set_disabled(false)
	get_node("Resume").grab_focus() # Resume is preferred option

func popup(val, died): # if died == true, then message is "You died!", otherwise "game paused"
	if val: # Popup appearing
		get_node("AnimationPlayer").play("popup")
		
		get_node("Resume").set_disabled(died)
		if died:
			get_node("Label1").set_text("YOU DIED!")
		else:
			get_node("Label1").set_text("GAME PAUSED")
	else: # Popup closing
		get_node("AnimationPlayer").play_backwards("popup")
	
	player_is_dead = died
	Music.set_paused(val and not died)

func _on_Pause_visibility_changed():
	if is_visible():
		get_node("../Pointer").show()
	else:
		get_tree().set_pause(false) # Ensure game is not paused when pause menu goes away
		get_node("../Pointer").hide()

func handle(func_name):
	if func_name == "resume" or func_name == "restart":
		call(func_name)
		return
	
	fade.begin_fade_out()
	fade.connect("fade_finished", self, func_name)

func resume():
	popup(false, false)

func restart():
	# Update the checkpoint selection node with all available starting points
	var c = get_node("CheckpointSelection")
	c.options += ["Start of level"] # Comes first (idx = 0)
	if GameData.data.current_section > 0:
		for num in range(1, GameData.data.current_section + 1):
			var name = "Section " + str(num)
			c.options += [name]
	print(c.options)
	c.update_options()
	c.show()

func main_menu():
	get_tree().set_pause(false)
	get_tree().change_scene("res://scenes/main_menu.scn")

func settings():
	get_tree().set_pause(false)
	get_tree().change_scene("res://scenes/settings.tscn")


func _on_CheckpointSelection_option_canceled():
	get_node("CheckpointSelection").options.clear()
	get_node("CheckpointSelection").hide()


func _on_CheckpointSelection_option_selected(option_idx):
	var c = get_node("CheckpointSelection")
	get_tree().set_pause(false) # Unpause game
	# Set current section to what was selected from the menu
	GameData.data.current_section = option_idx
	print("selected starting section idx: " + str(option_idx))
	
	# Reload the scene, rail will align to correct section
	get_tree().reload_current_scene()
