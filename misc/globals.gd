extends Node


## Stats
var day: int = 1:
	set(new_value):
		emit_signal("stat_changed", "day", new_value)
		day = new_value

var money: int:
	set(new_value):
		emit_signal("stat_changed", "money", new_value)
		money = new_value

## Upgrades
var slope_length: int
var slope_angle: int
var battery_efficiency: int
var extra_batteries: int

signal stat_changed(stat: String, new_value)
