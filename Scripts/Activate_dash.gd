extends Area2D

var cam
var has_shown_tutorial = false
var has_waited = false

func _ready():
	cam = $"../../PicholaFollower/Camera"
	$AnimatedSprite.cam = cam

func _process(delta):
	if has_waited and Input.is_action_just_pressed("ANY"):
		if $AnimatedSprite.visible:
			$"../../Pichola".unpause()
			$AnimatedSprite.visible = false

func _on_Activate_Jump_body_entered(body):
	if has_shown_tutorial:
		return
	
	body.canDash = true
	body.pause()
	$Sprite.visible = false
	$AnimatedSprite.global_position = cam.global_position
	$AnimatedSprite.visible = true
	has_shown_tutorial = true
	
	yield(get_tree().create_timer(1), "timeout")
	
	has_waited = true
