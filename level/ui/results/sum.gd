extends Label


@onready var text_template: String = text
@export var car: Car
@export var lerp_speed: float = 8
## record checks
@export var counters: Array[Counter]

var display_money: float
var display_mult: float = 1.0
var display_earnings: float

var total_money: int
var total_mult: float = 1.0
var total_earnings: int

var tallying_index: int = 0
var is_calculated: bool

signal sum_calculated


func _ready() -> void:
	text = text_template % [
		"0", 
		"1.00",
		"0"
	]


func sum_results() -> void:
	total_money = CalculatorUtil.mix_money_total(
		int(counters[0].target_value), 
		int(counters[1].target_value)
	)
	total_mult = CalculatorUtil.mix_multiplier_total(
		counters[2].target_value,
		counters[3].target_value
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
				is_calculated = true
				emit_signal("sum_calculated")
	
	text = text_template % [
		str(ceili(display_money)), 
		str(snapped(display_mult, 0.01)),
		str(ceili(display_earnings))
	]


func force_complete() -> void:
	display_money = total_money
	display_mult = total_mult
	display_earnings = total_earnings
	text = text_template % [
		str(ceili(total_money)), 
		str(snapped(total_mult, 0.01)),
		str(ceili(total_earnings))
	]
	
	tallying_index = 0
	is_calculated = true
	emit_signal("sum_calculated")
