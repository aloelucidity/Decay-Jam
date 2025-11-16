class_name LevelGenerator
extends Node2D


@export var car: Car
@export var car_pos_offset: Vector2

@export var camera: Camera2D

@export var slope_length: float
@export var slope_angle: float

@export var level_length: float
@export var level_depth: float
@export var sample_rate: float

@export var hill_frequency: float
@export var max_hill_strength: float

@export var bump_frequency: float
@export var bump_strength: float

var rng_seed: int
var polygon: Polygon2D
var height_map: PackedFloat64Array


func _ready() -> void:
	randomize()
	generate_level(randi_range(-100000, 100000))


func generate_level(_rng_seed: int) -> void:
	rng_seed = _rng_seed
	
	var hill_noise := FastNoiseLite.new()
	hill_noise.frequency = hill_frequency / 1000
	hill_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	hill_noise.fractal_weighted_strength = 0.2
	hill_noise.seed = rng_seed
	
	var bump_noise := FastNoiseLite.new()
	bump_noise.frequency = bump_frequency / 1000
	bump_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	bump_noise.seed = rng_seed
	
	var poly: PackedVector2Array
	var x: float = -slope_length - sample_rate
	while x <= -sample_rate:
		poly.append(Vector2(x, (-slope_length*slope_angle - sample_rate) * pow(-x/slope_length, 2) ))
		x += sample_rate
	
	x = 0
	var min_height: float = 0
	while x < level_length:
		var hill_strength: float = max_hill_strength * (x / level_length)
		var height: float = hill_noise.get_noise_1d(x) * hill_strength
		var y: float = height + (bump_noise.get_noise_1d(x) * bump_strength)
		poly.append(Vector2(x, y))
		height_map.append(y)
		
		if min_height < height:
			min_height = height
		x += sample_rate
	
	poly.append(Vector2(level_length, min_height + level_depth))
	poly.append(Vector2(-slope_length - sample_rate, min_height + level_depth))
	
	
	var static_body_2d := StaticBody2D.new()
	add_child(static_body_2d)
	
	var polygon_2d := Polygon2D.new()
	polygon_2d.polygon = poly
	static_body_2d.add_child(polygon_2d)
	
	var collision_2d := CollisionPolygon2D.new()
	collision_2d.polygon = poly
	static_body_2d.add_child(collision_2d)
	
	
	car.position = Vector2(-slope_length, -slope_length * slope_angle) + car_pos_offset
	car.rotation = PI/2 * slope_angle
	
	camera.limit_left = int(-slope_length - sample_rate)
	camera.limit_bottom = int(min_height + level_depth)
	camera.limit_right = int(level_length)
