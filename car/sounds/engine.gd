extends AudioStreamPlayer2D


@onready var car: Car = get_owner()
@onready var target_volume: float = volume_linear

@export var max_pitch: float
@export var pitch_up_speed: float
@export var pitch_down_speed: float
@export var sound_grace_frames: int
@export var idle_volume_multiplier: float = 1

var grace_timer: int


func _ready() -> void:
	volume_linear = 0


func _physics_process(delta: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	var engine_playing: bool = car.on_ground and car.has_battery(car.wheel_stats.energy_usage * abs(direction)) and sign(direction) != -sign(car.linear_velocity.x)
	if engine_playing:
		grace_timer = sound_grace_frames
	else:
		grace_timer -= 1
	
	var sound_playing: bool = grace_timer > 0 and not is_zero_approx(direction)
	var final_volume: float = target_volume * (abs(direction) if sound_playing else idle_volume_multiplier)
	if round(car.get_total_battery()) <= 0:
		final_volume = 0
	
	volume_linear = lerp(
		volume_linear, 
		final_volume, 
		delta * 4
	)
	
	var accel_speed: float = min(abs(car.linear_velocity.x) / (car.wheel_stats.torque / car.mass), 1.0)
	pitch_scale = lerp(
		pitch_scale, 
		(abs(direction) * max_pitch) if sound_playing else 1.0, 
		delta * accel_speed * (pitch_up_speed if sound_playing else pitch_down_speed)
	)
