extends AutoResizer


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blur: ColorRect = %Blur
@onready var results_label: Label = %ResultsLabel
@onready var sum: Label = %Sum

@export var intermission_path: String
@export var car: Car
@export var counters: Array[Counter]


var mix_amount: float = 0.0
var run_ended: bool
var run_end_buffer: float = 0.5
var transitioning: bool

@export var tallying_time: float = 0.75
var tallying_index: int
var tallying_timer: float


func _physics_process(delta: float) -> void:
	if run_ended:
		run_end_buffer -= delta
		if tallying_index <= counters.size():
			tallying_timer -= delta
			if tallying_timer <= 0:
				if tallying_index < counters.size():
					counters[tallying_index].tally_results()
				else:
					sum.sum_results()
				tallying_index += 1
				tallying_timer = tallying_time
	else:
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


func _input(event: InputEvent) -> void:
	if not run_ended: return
	if transitioning: return
	if not event is InputEventKey or not event.is_pressed(): return
	
	if tallying_index > counters.size() and sum.is_calculated:
		transitioning = true
		Globals.money += sum.total_earnings
		Globals.day += 1
		Transitions.change_scene_to(intermission_path)
	elif run_end_buffer <= 0:
		animation_player.play("transition", -1, INF)
		tallying_index = counters.size() + 1
		for counter in counters:
			counter.tally_results()
			counter.force_complete()
		sum.sum_results()
		sum.force_complete()
