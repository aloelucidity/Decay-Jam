extends TextureRect


@export var visible_color: Color
@export var invisible_color: Color
@export var lerp_speed: float = 4

@export var car: Car
@export var label: Label
@export var pos_offset: Vector2


func _process(delta: float) -> void:
	label.text = str(snapped(car.body.air_time, 0.01)) + "s"
	
	if car.body.air_time > car.body.air_time_threshold:
		modulate = lerp(modulate, visible_color, delta * lerp_speed)
		if modulate.a >= 0.98:
			modulate.a = 10
	else:
		modulate = lerp(modulate, invisible_color, delta * lerp_speed)
	
	position = car.get_screen_transform().get_origin() + pos_offset
