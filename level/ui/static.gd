extends ColorRect


@export var lerp_speed: float = 1
var noise_intensity: float


func _process(delta: float) -> void:
	noise_intensity = lerp(noise_intensity, 0.0, delta * lerp_speed)
	material.set_shader_parameter("noise_intensity", noise_intensity)
