extends HBoxContainer


@export var car: Car
@export var bevel_image: Texture2D
var bars: Array[ProgressBar]


func _ready() -> void:
	if is_instance_valid(car):
		car.connect("battery_used", battery_used)
		for battery: float in car.batteries:
			var bar := ProgressBar.new()
			bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			bar.fill_mode = bar.FILL_END_TO_BEGIN
			add_child(bar)
			
			var bevel := TextureRect.new()
			bevel.texture = bevel_image
			bevel.material = preload("res://level/ui/battery_bevel.tres")
			bevel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			bevel.set_anchors_preset(Control.PRESET_FULL_RECT)
			bar.add_child(bevel)
			
			bars.append(bar)


func battery_used() -> void:
	bars.remove_at(0)


func _process(_delta: float) -> void:
	var index: int = 0
	for bar: ProgressBar in bars:
		bar.value = car.batteries[index]
		index += 1
