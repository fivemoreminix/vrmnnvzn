
extends Area2D

# Member variables
var SPEED = 350 if GameData.data.difficulty == "Normal" else 300


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
	# Hit the player
	if area.is_in_group("Player"):
		# Duck typing at its best
		if not area.killed:
			area.kill()
	
	_hit_something()


func _on_shot_body_enter(body):
	# Hit the tilemap
	_hit_something()
