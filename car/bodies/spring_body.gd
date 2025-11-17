class_name SpringBody
extends Body


@onready var jump_sound: AudioStreamPlayer2D = %Jump

@export var base_jump_impulse: float
@export var wheel_jump_impulse: float

@export var jump_energy: float
@export var jump_cancel_multiplier: float = 1

var jump_cancelled: bool


func integrate_forces() -> void:
	super()
	
	var jump_impulse: float = base_jump_impulse
	jump_impulse += wheel_jump_impulse * car.wheel_stats.size
	
	if Input.is_action_just_pressed("move_up") and car.coyote_timer > 0 and car.has_battery(jump_energy):
		car.angular_velocity = 0
		car.apply_central_impulse(Vector2(0, -jump_impulse).rotated(car.rotation))
		car.use_battery(jump_energy)
		jump_sound.play()
		jump_cancelled = false
	
	if not car.on_ground and not jump_cancelled and not Input.is_action_pressed("move_up"):
		car.linear_velocity.y *= jump_cancel_multiplier
		jump_cancelled = true
