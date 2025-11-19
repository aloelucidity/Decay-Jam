class_name Counter
extends HBoxContainer


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label
@onready var new_record: Label = $NewRecord
@onready var value: Label = $Value
@onready var value_template: String = value.text

@export var car: Car
@export var stat: Car.CarStat
@export var lerp_speed: float = 4

var target_value: float
var display_value: float
var display_snap: float = 0.01
var is_tallying: bool


func tally_results():
	var stat_string: String
	var is_record: bool = false
	match stat:
		Car.CarStat.Fragments:
			stat_string = str(car.fragments_collected)
			target_value = CalculatorUtil.fragments_to_money(car.fragments_collected)
			display_snap = 1
		Car.CarStat.Robots:
			stat_string = str(car.robots_destroyed)
			target_value = CalculatorUtil.robots_to_money(car.robots_destroyed)
			display_snap = 1
		Car.CarStat.Distance:
			stat_string = str(int(CalculatorUtil.to_meters(car.distance_traveled)))
			target_value = CalculatorUtil.distance_to_multiplier(car.distance_traveled)
		Car.CarStat.Ascent:
			stat_string = str(int(CalculatorUtil.to_meters(car.distance_ascended)))
			target_value = CalculatorUtil.ascent_to_multiplier(car.distance_ascended)
	
	if is_record:
		target_value *= 2
	
	label.text = label.text % stat_string
	new_record.visible = is_record
	animation_player.play("transition")
	is_tallying = true


func _process(delta: float) -> void:
	if not is_tallying: return
	
	display_value = lerp(display_value, target_value, delta * lerp_speed)
	value.text = value_template % str(
		ceili(display_value) if display_snap == 1 else snapped(display_value, display_snap)
	)
