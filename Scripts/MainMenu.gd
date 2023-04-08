extends Control

#const first_scene = preload("res://Escenas/Pruebas.tscn")

var menu_origin_position := Vector2.ZERO
var manu_origin_size := Vector2.ZERO
var current_menu
export var mainGameScene : PackedScene

onready var animation = $AnimationPlayer
onready var FocusPlayer = $Button
onready var ButtonPlayer = $Button
onready var pichola_cam = $"../Escenario/PicholaFollower/Camera"
onready var SettingsPath = $"../Settings"
onready var PlayPath = $"res://Escenas/Pruebas.tscn"
onready var my_cam = $Camera2D
onready var huevo = $"../Escenario/Huevo"


func _ready():
	menu_origin_position = Vector2(0, 0)
	#$MarginContainer/LabelButtonContainer/Label/VBoxContainer/MarginContainer/Play.grab_focus()
	animation.play("fade_in")
	if $MainTheme.playing == false:
		$MainTheme.play()

func _on_Play_pressed():
	self.visible = false
	huevo.play()
	#pichola_cam.current = true
	#my_cam.current = false
	pichola_cam.make_current()
	

func _on_SETTINGS_pressed():
	self.visible = false
	var next_scene = get_node("../Settings")
	next_scene.show()

func _on_EXIT_pressed():
	get_tree().quit()
