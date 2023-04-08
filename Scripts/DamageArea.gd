extends Area2D

var pichola :KinematicBody2D

func _ready():
	pichola = $"../../Pichola"

func _on_Area2D_area_entered(area):
	pichola.respawn()
