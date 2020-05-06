
extends Area2D

# Member variables
const SPEED = 600


func _fixed_process(delta):
	translate(Vector2(0, -delta*SPEED).rotated(get_rot()))


func _ready():
	set_fixed_process(true)


func _hit_something():
	queue_free()


func _on_visibility_exit_screen():
	queue_free()


func _on_shot_area_enter(area):
	if area.is_in_group("Projectile"): return
	# Hit an enemy
	if (area.is_in_group("Enemy") and not area.is_in_group("Godmode")):
		# Duck typing at it's best
		if(!area.destroyed):
			area.destroy()
	
	_hit_something()


func _on_shot_body_enter(body):
	# Hit the tilemap
	_hit_something()
