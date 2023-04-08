class_name Parabola

var a = 1 
var b = 0
var c = 0

func _init(n_a = 1, n_b = 0, n_c = 0):
	a = n_a
	b = n_b
	c = n_c

func value_on(x):
	return a*pow(x,2) + b*x + c

func derivative_on(x):
	return 2*a*x + b

func second_derivative():
	return 2*a
