extends AnimatedSprite

var cam

func _physics_process(delta):
	if visible:
		global_position = cam.global_position
