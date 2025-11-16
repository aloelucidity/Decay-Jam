extends Camera2D


@export var car: Car
@export var pan_speed: float
@export var look_ahead_threshold: float
@export var look_ahead_amount: float

@export var air_offset: float
@export var ground_offset: float
@export var offset_lerp_speed: float

var cam_offset: Vector2
var look_direction: float


func _ready() -> void:
	if is_instance_valid(car):
		position = car.global_position
	get_viewport().connect("size_changed", window_resized)
	window_resized()


func _physics_process(delta: float) -> void:
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


# zoom testing
func window_resized() -> void:
	var base_size: float = (
		ProjectSettings.get_setting("display/window/size/viewport_width")
		+ ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	var window: Window = get_window()
	var new_zoom: float = float(window.size.x + window.size.y) / (base_size)
	zoom = Vector2(new_zoom, new_zoom)
