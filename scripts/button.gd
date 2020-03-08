extends Control

export(String) var parent_function_to_call = "the_function"

var white_flash # ../WhiteFlash
const FLASH_DUR = 0.3
var times = 0
var alpha = 0.0
var progress = 0.0 # out of 1.0
var raising = true # whether to add or subtract from alpha

func _ready():
	if not is_connected("pressed", self, "_on_button_pressed"): connect("pressed", self, "_on_button_pressed")

func _process(delta):
	if times >= 2: # if we finished the animation
		set_process(false)
		get_tree().get_root().set_disable_input(false) # re-enable input after button has animated (for simplicity / to prevent bugs)
		get_parent().handle(parent_function_to_call) # tell parent to begin the fading,
		return                                           # and use the given function name to change scenes or do whatever.
	
	if raising: progress += delta / (FLASH_DUR / 2)
	else:       progress -= delta / (FLASH_DUR / 2)
	alpha = min(progress * progress, 1.0) # y=x^2
	
	if alpha >= 1.0: raising = false
	elif alpha <= 0.1 and raising == false: raising = true; times += 1
	#white_flash.set_modulate(Color(1.0, 1.0, 1.0, alpha))

func _on_button_pressed():
	set_process(true)
	get_tree().get_root().set_disable_input(true) # prevent input while doing animation
	button_sound.play("button_sound")
	
	white_flash = get_parent().get_node("WhiteFlash")
	white_flash.show() # make it visible
	white_flash.edit_set_rect(get_rect()) # fit it over this button
	#white_flash.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
	get_parent().get_node("AnimationPlayer").play("flash")
