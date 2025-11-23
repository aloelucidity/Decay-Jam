extends AudioStreamPlayer


@export var target_volume: float


func _process(delta: float) -> void:
	volume_db = lerp(volume_db, target_volume, delta * 4)
