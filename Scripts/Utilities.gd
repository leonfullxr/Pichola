class_name Utilities
extends Node

## Rreturns the angle, but in the interval (-PI, PI]
static func normalizeAngle(angle :float) -> float:
	while angle <= -PI:
		angle += 2*PI
	
	while angle > PI:
		angle -= 2*PI
	
	return angle


