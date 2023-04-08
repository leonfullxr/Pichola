extends Control

signal game_paused
signal game_unpaused

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.is_paused = !is_paused

var is_paused = false setget set_is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused


func _on_Resume_Game_pressed():
	emit_signal("game_unpaused")
	self.is_paused = false


func _on_Exit_pressed():
	get_tree().quit()
