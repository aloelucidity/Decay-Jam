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
var stat_bests: Dictionary

## Shop
var owned_wheels: Array[WheelStats]
var owned_bodies: Array[BodyStats]
var equipped_wheel: WheelStats = preload("res://car/wheels/gear.tres"):
	set(new_value):
		emit_signal("wheel_equipped", new_value)
		equipped_wheel = new_value
var equipped_body: BodyStats = preload("res://car/bodies/stats/shopping_cart.tres"):
	set(new_value):
		emit_signal("body_equipped", new_value)
		equipped_body = new_value

signal stat_changed(stat: String, new_value)
signal wheel_equipped(wheel: WheelStats)
signal body_equipped(body: BodyStats)


func _ready() -> void:
	owned_wheels.append(equipped_wheel)
	owned_bodies.append(equipped_body)
