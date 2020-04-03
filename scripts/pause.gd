extends Panel

onready var fade = get_node("../Fade")

func _ready():
	set_process(true)

func _process(delta):
	if (Input.is_action_pressed("ui_cancel") or Input.is_action_pressed("pause")) and not \
	   get_node("Resume").is_disabled()                                           and not \
	   get_node("AnimationPlayer").is_playing(): resume()

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

func popup(val):
	if val: get_node("AnimationPlayer").play("popup")
	else:   get_node("AnimationPlayer").play_backwards("popup")

func _on_Pause_visibility_changed():
	if is_visible():
		get_node("../Pointer").show()
	else:
		get_tree().set_pause(false) # Ensure game is not paused when pause menu goes away
		get_node("../Pointer").hide()

func handle(func_name):
	if func_name == "resume":
		call("resume")
		return
	
	fade.begin_fade_out()
	fade.connect("fade_finished", self, func_name)

func resume():
	popup(false)

func restart():
	get_tree().reload_current_scene()

func main_menu():
	get_tree().change_scene("res://main_menu.scn")

func settings():
	get_tree().change_scene("res://scenes/settings.tscn")