class_name Body
extends Node2D


var car: Car


func integrate_forces():
	if abs(car.linear_velocity.x) > car.body_stats.drag_threshold:
		var drag_force: float = (abs(car.linear_velocity.x) - car.body_stats.drag_threshold)
		car.linear_velocity.x -= drag_force * (car.body_stats.drag/1000)
