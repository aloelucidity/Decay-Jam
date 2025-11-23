extends Node2D


@export var level_generator: LevelGenerator
@export var camera: Camera2D
var furthest_distance: float
var furthest_sample: int

const BASE_OBJ_PATH: String = "res://level/objects/%s.gd"
@onready var base_list: Dictionary[String, float] = preload("res://level/objects/object_list.tres").object_list
@export var object_chance: float


func _ready() -> void:
	seed(level_generator.rng_seed)


func _physics_process(_delta: float) -> void:
	var max_samples: int = level_generator.height_map.size() - 1
	var cam_right: float = camera.global_position.x + camera.get_viewport_rect().size.x / camera.zoom.x
	if cam_right > furthest_distance:
		var sample_length: int = floori(cam_right / level_generator.sample_rate) - furthest_sample
		var sample: int = furthest_sample
		while sample < min(furthest_sample + sample_length, max_samples):
			if randf() < object_chance:
				sample += spawn_object(sample)
			else:
				sample += 1
		
		furthest_distance = cam_right
		furthest_sample = sample


## returns the amount of samples used by the object
func spawn_object(sample: int) -> int:
	var difficulty: float = (sample * level_generator.sample_rate) / level_generator.level_length
	var object_list: Dictionary = base_list.duplicate()
	
	for key in object_list.keys():
		if object_list[key] > difficulty:
			object_list.erase(key)
	
	var weighted_list: Array[String]
	for key in object_list.keys():
		var score_match = 1 - (difficulty - object_list[key])
		for i in range(ceil(score_match * 10)):
			weighted_list.append(key)
	
	var picked_element: String = weighted_list[randi_range(0, weighted_list.size() - 1)]
	
	var max_samples: int = level_generator.height_map.size() - 1
	var object = load(BASE_OBJ_PATH % picked_element).new(level_generator)
	object.sample_width = min(object.sample_width, max_samples - sample)
	object.build(sample)
	add_child(object)
	return object.sample_width
