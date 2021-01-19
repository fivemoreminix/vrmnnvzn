extends Camera2D

var decay = 0.8 # How quickly the shaking stops: 0.0 to 1.0
var max_offset = Vector2(25, 10) # Max hor/ver shake in pixels
var max_roll = 0.1 # Max rotatation in radians (use sparingly)

var trauma = 0.0
var trauma_power = 2 # Trauma exponent. [2, 3]

func _ready():
	if is_current():
		Globals.set("current_camera", self) # Should be checked in _process if any bugs arise
	randomize()
	set_process(true)

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func shake():
	var amount = pow(trauma, trauma_power)
	set_rot(max_roll * amount * rand_range(-1, 1))
	var offset = Vector2()
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
	set("offset", offset)

func add_trauma(trauma): # trauma: float between 0.0 and 1.0
	self.trauma = min(1.0, self.trauma + trauma)
