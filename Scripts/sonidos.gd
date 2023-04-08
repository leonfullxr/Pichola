extends Node

func sonidoSalto():
	$salto.play()

func _on_salto_finished():
	$salto.stop()

func sonidoMainTheme():
	$mainTheme.play()

func sonidoDash():
	$dash.play()

func _on_dash_finished():
	$dash.stop()

func sonidoAndar():
	$andar.play()

func _on_andar_finished():
	$andar.stop()
