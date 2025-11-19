extends Label


enum DisplayStat {
	Money,
	Multiplier
}

@export var car: Car
@export var stat_to_track: DisplayStat 


func _process(_delta: float) -> void:
	var stat_string: String
	var prefix: String
	
	match stat_to_track:
		DisplayStat.Money:
			prefix = "$"
			stat_string = str(
				CalculatorUtil.calculate_money_total(
					car.fragments_collected, 
					car.robots_destroyed
				)
			)
		DisplayStat.Multiplier:
			prefix = "x"
			stat_string = str(
				snappedf(
					CalculatorUtil.calculate_multiplier_total(
						car.distance_traveled,
						car.distance_ascended
					), 
					0.01
				)
			)
	
	text = prefix + stat_string
