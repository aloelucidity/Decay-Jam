extends TextureRect


@export var animate_index: int = 1
@export var animate_range := Vector2(0.4, 0.6)
@export var animate_speed: float = 1

func _process(_delta: float) -> void:
	var elapsed: float = Time.get_unix_time_from_system()
	var difference: float = animate_range.y - animate_range.x
	texture.gradient.offsets[animate_index] = animate_range.x + difference/2 + (difference * sin(elapsed * animate_speed))
