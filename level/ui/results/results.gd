extends AutoResizer


@export var car: Car
@onready var blur: ColorRect = %Blur
var mix_amount: float = 0.0
var run_ended: bool


func _physics_process(delta: float) -> void:
	if run_ended: return
	var target_mix: float = 1 - car.end_timer / car.end_time_threshold
	mix_amount = lerp(mix_amount, target_mix, delta * 8)
	blur.material.set_shader_parameter("mix_amount", mix_amount)


func end_run() -> void:
	if run_ended: return
	run_ended = true
	blur.material.set_shader_parameter("mix_amount", 1.0)
	get_tree().paused = true
