extends Control


onready var MainMenuPath = $"../MainMenu"
func _ready():
	pass


func _on_Master_Slider_value_changed(value):
	if value == -45:
		AudioServer.set_bus_volume_db(0,true)
	else:
		AudioServer.set_bus_volume_db(0,false)
	AudioServer.set_bus_volume_db(0,value)


func _on_Back_pressed():
	self.visible = false
	var node = get_node("../MainMenu")
	node.show()

func _on_HSlider_value_changed(value):
	if value == -45:
		AudioServer.set_bus_volume_db(1,true)
	else:
		AudioServer.set_bus_volume_db(1,false)
	AudioServer.set_bus_volume_db(1,value)


func _on_HSlider2_value_changed(value):
	if value == -45:
		AudioServer.set_bus_volume_db(2,true)
	else:
		AudioServer.set_bus_volume_db(2,false)
	AudioServer.set_bus_volume_db(2,value)
