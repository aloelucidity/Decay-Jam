class_name AnimateGradient
extends Control


@export var do_animation: bool = true
@export var animate_index: int = 1
@export var animate_range := Vector2(0.4, 0.6)
@export var animate_speed: float = 1

var variable_id: String = "texture"

func _process(_delta: float) -> void:
	if not do_animation: return
	var elapsed: float = Time.get_unix_time_from_system()
	var difference: float = animate_range.y - animate_range.x
	self[variable_id].gradient.offsets[animate_index] = animate_range.x + difference/2 + (difference * sin(elapsed * animate_speed))
