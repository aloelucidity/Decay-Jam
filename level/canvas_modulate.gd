extends CanvasModulate

@export var car: Car
@export var darkness_color: Color

func _physics_process(_delta: float) -> void:
	if is_instance_valid(car):
		var light_percentage: float = min(100, car.get_total_battery())/100
		light_percentage /= car.body_stats.light_divider
		color = darkness_color * (1 - light_percentage) + Color.WHITE * light_percentage
