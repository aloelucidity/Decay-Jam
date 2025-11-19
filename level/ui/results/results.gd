extends AutoResizer


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blur: ColorRect = %Blur
@onready var results_label: Label = %ResultsLabel
@onready var sum: Label = %Sum

@export var car: Car
@export var counters: Array[Counter]


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
	animation_player.play("transition")
	get_tree().paused = true
	
	results_label.text = results_label.text % Globals.day
	tally_results()


func tally_results() -> void:
	for counter in counters:
		counter.tally_results()
		await get_tree().create_timer(0.5).timeout
	sum.sum_results()
