class_name Wheel
extends RigidBody2D


@onready var car: Car = get_owner()
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var on_ground: bool = false
var wheel_stats: WheelStats


func load_wheel_stats(_wheel_stats: WheelStats) -> void:
	wheel_stats = _wheel_stats
	physics_material_override = wheel_stats.physics_material
	sprite.frames = wheel_stats.frames
	sprite.play("default")
	collision_shape_2d.shape.radius = wheel_stats.size / 2


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	on_ground = get_colliding_bodies().size()
	
	var direction: float = Input.get_axis("move_left", "move_right")
	if on_ground and not is_zero_approx(direction) and car.has_battery(wheel_stats.energy_usage * abs(direction)):
		apply_torque(wheel_stats.torque / physics_material_override.friction * direction)
		car.use_battery(wheel_stats.energy_usage * abs(direction))


func _process(delta: float) -> void:
	sprite.global_rotation = 0
	sprite.speed_scale = angular_velocity / (wheel_stats.torque * delta) * 20
