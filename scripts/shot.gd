
extends Area2D

# Member variables
const SPEED = 600

export var Damage = 1

var hit = false


func _process(delta):
	if hit:
		queue_free()
	else:
		translate(Vector2(0, -delta*SPEED).rotated(get_rot()))


func _ready():
	set_process(true)


func _hit_something():
	if (hit):
		return
	hit = true
	set_process(false)
	#hide()
	queue_free()
	#get_node("anim").play("splash")


func _on_visibility_exit_screen():
	queue_free()


func _on_shot_area_enter(area):
	# Hit an enemy or asteroid
	if (area.has_method("destroy")):
		# Duck typing at it's best
		area.destroy()
		_hit_something()


func _on_shot_body_enter(body):
	# Hit the tilemap
	_hit_something()
