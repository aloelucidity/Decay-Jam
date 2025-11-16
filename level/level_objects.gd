extends Node2D


@export var level_generator: LevelGenerator
@export var camera: Camera2D
var furthest_distance: float
var furthest_sample: int


func _ready() -> void:
	seed(level_generator.rng_seed)


func _physics_process(_delta: float) -> void:
	var cam_right: float = camera.global_position.x + camera.get_viewport_rect().size.x / camera.zoom.x
	if cam_right > furthest_distance:
		var sample_length: int = floori(cam_right / level_generator.sample_rate) - furthest_sample
		var sample: int = furthest_sample
		while sample < furthest_sample + sample_length:
			var object := CoinLine.new(level_generator)
			object.build(sample)
			add_child(object)
			
			sample += object.sample_width
		
		furthest_distance = cam_right
		furthest_sample = sample
		
