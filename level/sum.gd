extends Label


@onready var text_template: String = text
@export var car: Car
@export var lerp_speed: float = 8

var display_money: float
var display_mult: float = 1.0
var display_earnings: float

var total_money: int
var total_mult: float = 1.0
var total_earnings: int

var tallying_index: int = 0

signal sum_calculated


func sum_results() -> void:
	total_money = CalculatorUtil.calculate_money_total(
		car.fragments_collected, 
		car.robots_destroyed
	)
	total_mult = CalculatorUtil.calculate_multiplier_total(
		car.distance_traveled,
		car.distance_ascended
	)
	total_earnings = ceil(total_money * total_mult)
	tallying_index = 1


func _process(delta: float) -> void:
	if tallying_index <= 0: return
	match tallying_index:
		1:
			display_money = lerp(display_money, float(total_money), delta * lerp_speed)
			if ceili(display_money) == total_money:
				tallying_index += 1
		2:
			display_mult = lerp(display_mult, float(total_mult), delta * lerp_speed)
			if is_equal_approx(snapped(display_mult, 0.01), snapped(total_mult, 0.01)):
				display_mult = total_mult
				tallying_index += 1
		3:
			display_earnings = lerp(display_earnings, float(total_earnings), delta * lerp_speed)
			if ceili(display_earnings) == total_earnings:
				tallying_index = 0
				emit_signal("sum_calculated")
	
	text = text_template % [
		str(ceili(display_money)), 
		str(snapped(display_mult, 0.01)),
		str(ceili(display_earnings))
	]
