extends TextureRect


@export var scroll_speed := Vector2(10, 10)


func _process(delta: float) -> void:
	position += scroll_speed * delta
	position.x = wrap(position.x, floor(-size.x / 2), 0)
	position.y = wrap(position.y, floor(-size.y / 2), 0)
