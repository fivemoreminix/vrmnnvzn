extends Area2D

signal enemy_destroyed(area)

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
	if area.is_in_group("BulletNoCollide"): return
	# Hit an enemy
	if (area.is_in_group("Enemy") and not area.is_in_group("Godmode")):
		# Duck typing at it's best
		if(!area.destroyed):
			if area.destroy(): # true if enemy died when this function is called
				emit_signal("enemy_destroyed", area)
	
	_hit_something()


func _on_shot_body_enter(body):
	# Hit the tilemap
	_hit_something()
