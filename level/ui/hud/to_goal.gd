extends Label


@onready var base_text = text
@export var car: Car
@export var level_generator: LevelGenerator


func _process(_delta: float) -> void:
	var to_goal := int(level_generator.level_length - car.position.x)
	to_goal = max(to_goal, 0)
	to_goal = int(CalculatorUtil.to_meters(to_goal))
	text = base_text % str(to_goal)
