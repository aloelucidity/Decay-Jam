class_name Speedometer
extends ColorRect

const METER_WIDTH: float = 32

@onready var label: Label = $Label
@onready var label_base_text: String = label.text
@export var car: Car


func _ready() -> void:
	var max_speed: float = car.wheel_stats.torque / car.wheel_stats.physics_material.friction / car.mass
	var drag_threshold: float = car.body_stats.drag_threshold
	material.set_shader_parameter("region3", drag_threshold / max_speed)


func _process(_delta: float) -> void:
	var speed: float = abs(car.linear_velocity.x)
	var max_speed: float = car.wheel_stats.torque / car.wheel_stats.physics_material.friction / car.mass
	
	material.set_shader_parameter("indicator_angle", speed / max_speed)
	label.text = label_base_text % int(to_kilometers_per_hour(speed))


func to_kilometers_per_hour(pixels_per_second: float) -> float:
	var meters_per_second: float = abs(pixels_per_second) / METER_WIDTH
	var kilometers_per_hour: float = (meters_per_second * 60 * 60) / 1000
	return kilometers_per_hour
