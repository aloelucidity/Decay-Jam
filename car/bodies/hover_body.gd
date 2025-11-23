class_name HoverBody
extends SpringBody


@export var hover_multiplier := Vector2.ONE
@export var hover_thrust: float
@export var hover_energy: float
@export var max_hover_length: float
var hover_timer: float


func integrate_forces() -> void:
	super()
	
	var delta: float = get_physics_process_delta_time()
	if Input.is_action_pressed("move_up") and not car.on_ground and car.has_battery(hover_energy) and hover_timer > 0:
		if car.linear_velocity.y > -hover_thrust * delta:
			car.apply_central_impulse(Vector2(0, -hover_thrust).rotated(car.rotation) * hover_multiplier)
			car.use_battery(hover_energy)
			hover_timer -= delta
	
	if car.on_ground:
		hover_timer = max_hover_length
