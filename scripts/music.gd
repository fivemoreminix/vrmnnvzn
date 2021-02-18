extends StreamPlayer

const TRANS_TYPE = Tween.TRANS_SINE

onready var tween = get_node("Tween")


func _ready():
	pass


func set_ensure_playing(stream):
	if get_stream() != stream:
		set_stream(stream)
		play()


# Stops audio playback after fading out.
func fade_out(length = 1.0):
	tween.interpolate_property(self, "volume_db", 0, -80, length, TRANS_TYPE, Tween.EASE_IN, 0)
	tween.start()
	# Music is stopped when the Tween is finished


func _on_Tween_tween_complete( object, key ):
	self.stop() # Stop the music after fading out
