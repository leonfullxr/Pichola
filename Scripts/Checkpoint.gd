extends Area2D

export var check_point_priority :int = 0
var pichola :KinematicBody2D

func _ready():
	pichola = $"../../Pichola"

func _on_Checkpoint_body_entered(body):
	pichola.update_check_point(self)
