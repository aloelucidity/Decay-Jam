extends VBoxContainer


@export var car: Car
var bars: Array[ProgressBar]


func _ready() -> void:
	if is_instance_valid(car):
		car.connect("battery_used", battery_used)
		for battery: float in car.batteries:
			var bar := ProgressBar.new()
			add_child(bar)
			bars.append(bar)


func battery_used() -> void:
	bars.remove_at(0)


func _process(_delta: float) -> void:
	var index: int = 0
	for bar: ProgressBar in bars:
		bar.value = car.batteries[index]
		index += 1
