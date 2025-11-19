class_name Body
extends Node2D


var car: Car


func integrate_forces():
	car.linear_damp = car.body_stats.damp
	if abs(car.linear_velocity.x) > car.body_stats.resistance_threshold:
		car.linear_damp = car.body_stats.resistance
