class_name RobotSpawner
extends LevelObject


func _init(_level_generator: LevelGenerator) -> void:
	super(_level_generator)
	sample_width = 3


func build(sample: int) -> void:
	var robot_obj: CharacterBody2D = preload("res://level/scenes/robot/robot.tscn").instantiate()
	robot_obj.position = get_sample_pos(sample)
	robot_obj.car = level_generator.car
	add_child(robot_obj)
