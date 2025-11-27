extends Camera2D


@export var car: Car
@export var pan_speed: float
@export var look_ahead_threshold: float
@export var look_ahead_amount: float

@export var air_offset: float
@export var ground_offset: float
@export var offset_lerp_speed: float
@export var shake_lerp_speed: float = 8
@export var zoom_lerp_speed: float = 6
@export var zoom_decay_speed: float = 3

var cam_offset: Vector2
var look_direction: float
var shake_intensity: float
var zoom_out: float
var zoom_out_vector: Vector2


func _ready() -> void:
	if is_instance_valid(car):
		position = car.global_position


func _physics_process(delta: float) -> void:
	zoom = Vector2.ONE - zoom_out_vector
	
	zoom_out_vector = lerp(zoom_out_vector, Vector2(zoom_out, zoom_out), delta * zoom_lerp_speed)
	zoom_out = lerp(zoom_out, 0.0, delta * zoom_decay_speed)
	
	shake_intensity = lerp(shake_intensity, 0.0, delta * shake_lerp_speed)
	shake_intensity = max(0, shake_intensity)
	offset = Vector2(
		randf_range(-1.0, 1.0) * shake_intensity, 
		randf_range(-1.0, 1.0) * shake_intensity
	)
	
	if is_instance_valid(car):
		if abs(car.linear_velocity.x * delta) < look_ahead_threshold:
			look_direction = (car.linear_velocity.x * delta) / look_ahead_threshold
		else:
			look_direction = signf(car.linear_velocity.x)
		
		var target_offset := Vector2(0, ground_offset) if car.on_ground else Vector2(0, air_offset)
		cam_offset = cam_offset.lerp(target_offset, delta * offset_lerp_speed)
		
		var follow_pos: Vector2 = car.position + Vector2(look_direction * look_ahead_amount, 0)
		follow_pos += car.linear_velocity * delta * 1.4 * pan_speed 
		position += (follow_pos + cam_offset - position) / pan_speed
