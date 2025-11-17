class_name HoverBody
extends SpringBody


@export var hover_thrust: float
@export var hover_rot_speed: float = 1
@export_range(0, 360, 0.1, "radians_as_degrees") var hover_rotation: float
@export var hover_energy: float


func integrate_forces() -> void:
	super()
	
	var delta: float = get_physics_process_delta_time()
	var direction: float = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_pressed("move_up") and not car.on_ground and car.has_battery(hover_energy):
		if car.linear_velocity.y > -hover_thrust * delta:
			car.apply_central_impulse(Vector2(0, -hover_thrust).rotated(rotation))
			car.use_battery(hover_energy)
		
		var target_rot: float = hover_rotation * direction
		car.rotation = lerp_angle(car.rotation, target_rot, delta * hover_rot_speed)
