extends Node2D


@export var intermission_path: String
@export var car: Car


func end_run() -> void:
	var earnings: int = calculate_earnings(car.money, car.multiplier)
	Globals.money += earnings
	Globals.day += 1
	get_tree().change_scene_to_file(intermission_path)


func calculate_earnings(money: int, multiplier: float) -> int:
	return ceil(float(money) * (multiplier / 1000))
