extends TextureRect


@export var visible_color: Color
@export var invisible_color: Color
@export var lerp_speed: float = 4

@export var car: Car
@export var label: Label
@export var pos_offset: Vector2


func _ready() -> void:
	get_window().connect("size_changed", window_resized)
	window_resized()


func _process(delta: float) -> void:
	label.text = str(snapped(car.body.air_time, 0.01))
	
	if car.body.air_time > car.body.air_time_threshold:
		modulate = lerp(modulate, visible_color, delta * lerp_speed)
		if modulate.a >= 0.98:
			modulate.a = 10
	else:
		modulate = lerp(modulate, invisible_color, delta * lerp_speed)
	
	position = car.get_screen_transform().get_origin() + pos_offset * scale


func window_resized() -> void:
	var base_size: float = (
		ProjectSettings.get_setting("display/window/size/viewport_width")
		+ ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	var window: Window = get_window()
	if is_instance_valid(window):
		var new_zoom: float = float(window.size.x + window.size.y) / base_size
		scale = Vector2(new_zoom, new_zoom)
