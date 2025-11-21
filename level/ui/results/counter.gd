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
var is_record: bool


func tally_results():
	if is_tallying: return
	
	var stat_string: String
	match stat:
		Car.CarStat.Fragments:
			var stat_val: int = car.fragments_collected
			if stat_val > Globals.stat_bests.get(stat, -1):
				Globals.stat_bests[stat] = stat_val
				is_record = true
				
			stat_string = str(stat_val)
			target_value = CalculatorUtil.fragments_to_money(car.fragments_collected)
			display_snap = 1
		Car.CarStat.Robots:
			var stat_val: int = car.robots_destroyed
			if stat_val > Globals.stat_bests.get(stat, -1):
				Globals.stat_bests[stat] = stat_val
				is_record = true
			
			stat_string = str(stat_val)
			target_value = CalculatorUtil.robots_to_money(car.robots_destroyed)
			display_snap = 1
		Car.CarStat.Distance:
			var stat_val: float = car.distance_traveled
			if stat_val > Globals.stat_bests.get(stat, -1.0):
				Globals.stat_bests[stat] = stat_val
				is_record = true
			
			stat_string = str(int(CalculatorUtil.to_meters(stat_val)))
			target_value = CalculatorUtil.distance_to_multiplier(stat_val)
		Car.CarStat.Ascent:
			var stat_val: float = car.distance_ascended
			if stat_val > Globals.stat_bests.get(stat, -1.0):
				Globals.stat_bests[stat] = stat_val
				is_record = true
			
			stat_string = str(int(CalculatorUtil.to_meters(stat_val)))
			target_value = CalculatorUtil.ascent_to_multiplier(stat_val)
	
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


func force_complete() -> void:
	is_tallying = false
	display_value = target_value
	value.text = value_template % str(
		ceili(display_value) if display_snap == 1 else snapped(display_value, display_snap)
	)
	animation_player.play("transition", -1, INF)
