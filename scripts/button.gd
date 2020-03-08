extends Control

export(String) var parent_function_to_call = "the_function"

func _ready():
	if not is_connected("pressed", self, "_on_button_pressed"): connect("pressed", self, "_on_button_pressed")

func _on_button_pressed():
	button_sound.play("button_sound")
	get_parent().get_node("ButtonFlasher").flash(get_rect())
	get_parent().get_node("ButtonFlasher").connect("flash_finished", self, "_on_flash_finished")

func _on_flash_finished():
	get_parent().handle(parent_function_to_call) # tell parent to begin the fading,
                                                 # and use the given function name to change scenes or do whatever.
