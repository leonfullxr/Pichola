extends Area2D


export var lock_x :bool = true
export var lock_y :bool = true
export var unlock_x :bool = false
export var unlock_y :bool = false
export var unlock_on_exit :bool = true
export var revert_zoom_on_exit :bool = true
export var zomom_on_exit = -1
export var zoom :float = -1.0


var picholaFollower :Node2D
var orig_zoom : Vector2 = Vector2.ONE
var zoom_tween = Tween.new()

func _ready():
	picholaFollower = $"../../PicholaFollower"
	get_parent().call_deferred("add_child", zoom_tween)

func _on_CameraModifier_body_entered(body):
	if lock_x:
		picholaFollower.x_locked = true
		if $Where:
			picholaFollower.position.x = $Where.global_position.x
	
	if lock_y:
		picholaFollower.y_locked = true
		if $Where:
			picholaFollower.position.y = $Where.global_position.y
	
	
	if unlock_x:
		picholaFollower.x_locked = false
	
	if unlock_y:
		picholaFollower.y_locked = false
	
	if zoom > 0:
		orig_zoom = picholaFollower.get_node("Camera").zoom
		zoom_tween.interpolate_property(picholaFollower.get_node("Camera"), "zoom", picholaFollower.get_node("Camera").zoom, Vector2.ONE * zoom, 1, 1)
		zoom_tween.start()


func _on_CameraModifier_body_exited(body):
	if unlock_on_exit:
		picholaFollower.x_locked = false
		picholaFollower.y_locked = false
	if revert_zoom_on_exit:
		if zomom_on_exit > 0:
			zoom_tween.interpolate_property(picholaFollower.get_node("Camera"), "zoom", picholaFollower.get_node("Camera").zoom, Vector2.ONE * zomom_on_exit, 1, 1)
		else:
			zoom_tween.interpolate_property(picholaFollower.get_node("Camera"), "zoom", picholaFollower.get_node("Camera").zoom, orig_zoom, 1, 1)
		zoom_tween.start()
