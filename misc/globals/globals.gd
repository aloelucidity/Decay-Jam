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
var equipped_wheel: WheelStats:
	set(new_value):
		emit_signal("wheel_equipped", new_value)
		equipped_wheel = new_value
var equipped_body: BodyStats:
	set(new_value):
		emit_signal("body_equipped", new_value)
		equipped_body = new_value

signal stat_changed(stat: String, new_value)
signal wheel_equipped(wheel: WheelStats)
signal body_equipped(body: BodyStats)


func reset() -> void:
	day = 1
	money = 0
	
	slope_length = 0
	slope_angle = 0
	battery_efficiency = 0
	extra_batteries = 0
	stat_bests = {}
	
	equipped_wheel = preload("res://car/wheels/gear.tres")
	equipped_body = preload("res://car/bodies/stats/shopping_cart.tres")
	
	owned_wheels = []
	owned_bodies = []
	owned_wheels.append(equipped_wheel)
	owned_bodies.append(equipped_body)


func _ready() -> void:
	reset()
