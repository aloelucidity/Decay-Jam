extends PointLight2D


@onready var car: Car = get_owner()


func _process(delta: float) -> void:
	var light_percentage: float = min(100, car.get_total_battery())/100
	texture_scale = lerpf(texture_scale, light_percentage, delta * 4)
