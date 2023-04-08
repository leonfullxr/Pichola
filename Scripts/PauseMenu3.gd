extends Control

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_node("../MainMenu").my_cam.current = true
		get_node("../MainMenu").pichola_cam.current = false
		get_node("../MainMenu").my_cam.make_current()

func toggle_pause():
	if self.visible:
		self.hide()
		get_tree().paused = false
	else:
		self.show()
		get_tree().paused = true

func _on_Button_pressed():
	#emit_signal("game_unpaused")
	#self.is_paused = false
	self.hide()

func _on_Button2_pressed():
	var node = get_node("../MainMenu")
	node.show()
	self.hide()

func _on_Button3_pressed():
	get_tree().quit()
