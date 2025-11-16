class_name LevelObject
extends Node2D


var sample_width: int = 1
var level_generator: LevelGenerator


func _init(_level_generator: LevelGenerator) -> void:
	level_generator = _level_generator


func get_sample_pos(sample: int) -> Vector2:
	var x: float = sample * level_generator.sample_rate
	var y: float = level_generator.height_map[sample]
	return Vector2(x, y)


func build(_sample: int) -> void:
	pass
