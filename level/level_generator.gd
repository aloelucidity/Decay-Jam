class_name LevelGenerator
extends Node2D


@export var car: Car
@export var car_pos_offset: Vector2
@export var camera: Camera2D

@export_group("Level")
@export var level_length: float
@export var level_depth: float
@export var sample_rate: float

@export_group("Slope")
@export var base_slope_length: float
@export var extra_slope_length: float
@export var max_slope_angle: float

@export_group("Terrain")
@export var hill_frequency: float
@export var max_hill_strength: float

@export var bump_frequency: float
@export var bump_strength: float

@export_group("Platform")
@export var platform_hill_frequency: float
@export var platform_placer_frequency: float
@export var platform_placer_threshold: float

@export var min_platform_offset: float
@export var max_platform_offset: float

var rng_seed: int
var polygon: Polygon2D
var height_map: PackedFloat64Array


func _ready() -> void:
	randomize()
	generate_level(randi_range(-100000, 100000))


func generate_level(_rng_seed: int) -> void:
	rng_seed = _rng_seed
	
	var static_body_2d := StaticBody2D.new()
	add_child(static_body_2d)
	
	var hill_noise := FastNoiseLite.new()
	hill_noise.frequency = hill_frequency / 1000
	hill_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	hill_noise.fractal_weighted_strength = 0.2
	hill_noise.seed = rng_seed
	
	var bump_noise := FastNoiseLite.new()
	bump_noise.frequency = bump_frequency / 1000
	bump_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	bump_noise.seed = rng_seed
	
	var platform_hill_noise := FastNoiseLite.new()
	platform_hill_noise.frequency = platform_hill_frequency / 1000
	platform_hill_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	platform_hill_noise.fractal_weighted_strength = 0.2
	platform_hill_noise.seed = rng_seed + 1
	
	var platform_placer_noise := FastNoiseLite.new()
	platform_placer_noise.frequency = platform_placer_frequency / 1000
	platform_placer_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	platform_placer_noise.seed = rng_seed + 1
	
	var slope_length: float = base_slope_length + extra_slope_length * Globals.slope_length
	var slope_angle_mult := float(Globals.slope_angle) / 8.0
	var slope_angle: float = max_slope_angle * slope_angle_mult
	
	var poly: PackedVector2Array
	var x: float = -slope_length - sample_rate
	while x <= -sample_rate:
		poly.append(Vector2(x, (-slope_length*slope_angle - sample_rate) * pow(-x/slope_length, 1.5) ))
		x += sample_rate
	
	x = 0
	var min_height: float = 0
	var platform_buffer: PackedVector2Array
	while x < level_length:
		var hill_strength: float = max_hill_strength * (x / level_length)
		var height: float = hill_noise.get_noise_1d(x) * hill_strength
		var y: float = height + (bump_noise.get_noise_1d(x) * bump_strength)
		poly.append(Vector2(x, y))
		height_map.append(y)
		
		var platform_placer: float = platform_placer_noise.get_noise_1d(x)
		if platform_placer > platform_placer_threshold:
			var platform_height: float = y - min_platform_offset 
			platform_height -= platform_hill_noise.get_noise_1d(x) * hill_strength
			platform_height = clamp(platform_height, y - max_platform_offset, y - min_platform_offset)
			platform_buffer.append(Vector2(x, platform_height))
		else:
			if platform_buffer.size() > 3:
				place_platform(platform_buffer, static_body_2d)
			platform_buffer.clear()
		
		if min_height < height:
			min_height = height
		x += sample_rate
	
	poly.append(Vector2(level_length, min_height + level_depth))
	poly.append(Vector2(-slope_length - sample_rate, min_height + level_depth))
	
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


func place_platform(points: PackedVector2Array, body: StaticBody2D) -> void:
	var poly_points = points.duplicate()
	poly_points.append(
		points[points.size() - 1] + Vector2(0, 100000)
	)
	poly_points.append(
		points[0] + Vector2(0, 100000)
	)
	
	var collision_2d := CollisionPolygon2D.new()
	collision_2d.build_mode = collision_2d.BUILD_SEGMENTS
	collision_2d.polygon = poly_points
	collision_2d.one_way_collision = true
	collision_2d.one_way_collision_margin = 0.1
	body.add_child(collision_2d)

	var line_2d := Line2D.new()
	line_2d.points = points
	line_2d.width = 4
	body.add_child(line_2d)
