extends Sprite

func play():
	$AnimationPlayer.play("Rompe")

func se_he_abierto():
	$"../Pichola".visible = true
	$"../Pichola".canMove = true
