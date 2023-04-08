extends Node2D

export var pichola_path :String
export var is_visible :bool = false
export var cam_scale :float = 1.0
var pichola :KinematicBody2D
var target :Vector2 = Vector2.ZERO
var following_pichola_x = true
var following_pichola_y = true
var following_speed :float = 8000
var regular_x_distance = 1600
var regular_y_distance = 800
var x_offset :float = 3600 # when runnuing
var y_offset :float = 1200 # when falling
var x_locked :bool = false
var y_locked :bool = false

var is_paused = false

func _ready():
	$Sprite.visible = is_visible
	pichola = get_node(pichola_path)
	pichola.connect("jump", self, "picholaJumped")
	pichola.connect("exrta_jump", self, "extraOrWallJumed")
	pichola.connect("wall_jump", self, "extraOrWallJumed")
	pichola.connect("below_jum_height", self, "returnTopicholaIn")
	pichola.connect("flor_touched", self, "returnTopicholaIn")
	pichola.connect("dashed", self, "returnTopicholaIn")
	

func _physics_process(delta):
	if is_paused:
		return
	
	if following_pichola_x:
		target.x = pichola.position.x
	
	if following_pichola_y:
		target.y = pichola.position.y
	
	var translation :Vector2 = (target + Vector2(calcXOffset(delta), calcYOffset(delta))) - position
	
	if x_locked:
		translation.x = 0
	elif translation.length() == 0:
		pass
	elif abs(translation.x) > following_speed * abs(translation.x/translation.length()) * delta:
		translation.x = (translation.x/translation.length()) * following_speed * delta * (abs(translation.x) / regular_x_distance)
	
	if y_locked:
		translation.y = 0
	elif translation.length() == 0:
		pass
	elif abs(translation.y) > following_speed * abs(translation.y/translation.length()) * delta:
		translation.y = (translation.y/translation.length()) * following_speed * delta * (abs(translation.y) / regular_y_distance)
	
	position += translation


var offset_moving_speed = 100
func calcXOffset(delta) -> float:
	if pichola.velocity.x != 0:
		return clamp(1.1 * x_offset * pichola.velocity.x / pichola.MAX_SPEED, -x_offset, x_offset) * cam_scale
	
	if pichola.looking_rigth:
		return x_offset/3 * cam_scale
	else:
		return -x_offset/3 * cam_scale
	


func calcYOffset(delta) -> float:
	if pichola.velocity.y == 0:
		return -y_offset * cam_scale
	
	if not following_pichola_y:
		return -y_offset * cam_scale
	
	var increase_factor = 3
	return clamp(increase_factor * y_offset * pichola.velocity.y / pichola.MAX_FALLING_SPEED, -increase_factor*y_offset, increase_factor*y_offset) * cam_scale

func picholaJumped():
	target = pichola.jump_origin

	following_pichola_y = false

func extraOrWallJumed():
	returnTopicholaIn(0)

func returnTopicholaIn(seconds :float = 0.05):
	if seconds > 0.0:
		yield(get_tree().create_timer(seconds), "timeout")
	
	following_pichola_y = true
	following_pichola_x = true
