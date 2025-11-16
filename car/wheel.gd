class_name Wheel
extends RigidBody2D


@onready var car: Car = get_owner()

var on_ground: bool = false


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	on_ground = get_colliding_bodies().size()
	
	var direction: float = Input.get_axis("move_left", "move_right")
	if on_ground and not is_zero_approx(direction) and car.has_battery(car.wheel_energy * abs(direction)):
		apply_torque(car.wheel_torque * direction)
		car.use_battery(car.wheel_energy * abs(direction))
