class_name Body
extends Node2D


@export var rot_speed: float = 1.3
@export var angular_lerp_speed: float = 0.3
@export var boost_grace: float = 0.04
@export var boost_multiplier: float = 150
@export var boost_zoom: float = 0.25
@export var max_boost_zoom_speed: float = 1000
@export var air_time_threshold: float = 0.3
var car: Car

var air_time: float = 0
var grounded_wheels: int = 0
var boost_timer: float = 0

func integrate_forces():
	car.linear_damp = car.body_stats.damp
	if abs(car.linear_velocity.x) > car.body_stats.resistance_threshold:
		car.linear_damp = car.body_stats.resistance
	
	var delta: float = get_physics_process_delta_time()
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0 and car.coyote_timer <= 0:
		car.rotation += rot_speed * direction * delta
		car.angular_velocity = lerp(car.angular_velocity, 0.0, delta * angular_lerp_speed)
	
	grounded_wheels = 0
	for wheel: Wheel in car.wheels:
		if wheel.on_ground:
			grounded_wheels += 1
	
	if grounded_wheels == 0:
		air_time += delta
		if air_time > air_time_threshold:
			boost_timer = boost_grace
	
	elif grounded_wheels > 0:
		boost_timer -= delta
		if boost_timer <= 0:
			air_time = 0
	
	if grounded_wheels > 1 and boost_timer >= 0:
		car.linear_velocity.x += air_time * boost_multiplier
		car.linear_velocity.y = 100
		car.angular_velocity = 0
		boost_timer = 0
		air_time = 0
		
		var zoom_out: float = boost_zoom * min(
			car.linear_velocity.x / max_boost_zoom_speed, 
			max_boost_zoom_speed
		)
		car.camera_2d.zoom_out = zoom_out
