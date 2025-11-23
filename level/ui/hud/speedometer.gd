class_name Speedometer
extends ColorRect


@onready var label: Label = $Label
@onready var label_base_text: String = label.text
@export var car: Car


func get_max_speed() -> float:
	var max_speed: float = car.wheel_stats.torque
	max_speed /= car.wheel_stats.physics_material.friction
	max_speed /= 100
	return max_speed


func _ready() -> void:
	var resistance_threshold: float = car.body_stats.resistance_threshold
	material.set_shader_parameter("region3", resistance_threshold / get_max_speed())


func _process(_delta: float) -> void:
	var speed: float = abs(car.linear_velocity.x)
	material.set_shader_parameter("indicator_angle", speed / get_max_speed())
	label.text = label_base_text % int(CalculatorUtil.to_kilometers_per_hour(speed))
