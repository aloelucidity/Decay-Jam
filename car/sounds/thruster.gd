extends AudioStreamPlayer2D


@onready var body: HoverBody = get_owner()
@onready var car: Car = body.car

@onready var target_volume: float = volume_linear

@export var max_pitch: float
@export var pitch_up_speed: float
@export var pitch_down_speed: float

var grace_timer: int


func _ready() -> void:
	volume_linear = 0


func _physics_process(delta: float) -> void:
	var thrust_conditions: bool = (
		Input.is_action_pressed("move_up") and 
		not car.on_ground and
		car.has_battery(body.hover_energy)
	)
	
	var sound_playing: bool = thrust_conditions
	var final_volume: float = target_volume if sound_playing else 0.0
	
	volume_linear = lerp(
		volume_linear, 
		final_volume, 
		delta * 4
	)
	
	pitch_scale = lerp(
		pitch_scale, 
		max_pitch if sound_playing else 1.0, 
		delta * (pitch_up_speed if sound_playing else pitch_down_speed)
	)
