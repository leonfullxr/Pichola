extends Area2D

var cam
var has_shown_tutorial = false
var has_waited = false

func _ready():
	cam = $"../../PicholaFollower/Camera"


func _on_Activate_Jump_body_entered(body):
	if has_shown_tutorial:
		return
	$Sprite.visible = false
	$AnimatedSprite.global_position = cam.global_position
	$AnimatedSprite.visible = true
	has_shown_tutorial = true
