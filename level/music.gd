extends AudioStreamPlayer


@export var car: Car
@export var speed_thresholds: Array[float]
@export var tween_time: float

var music_level: int = 0
var last_music_level: int = 0
var starting_volume: float


func _ready() -> void:
	starting_volume = volume_linear


func _process(delta: float) -> void:
	var ending_volume: float = car.end_timer / car.end_time_threshold
	volume_linear = lerp(volume_linear, starting_volume * ending_volume, delta * 4)

	music_level = 0
	var total_speed: float = car.linear_velocity.length() + abs(car.angular_velocity)
	for i in range(speed_thresholds.size()):
		if total_speed > speed_thresholds[i]:
			music_level = i + 1
	
	if last_music_level != music_level:
		if music_level > 0:
			change_sync_stream_volume(0, 3)
		else:
			change_sync_stream_volume(-60, 3)

		if music_level > 1:
			change_sync_stream_volume(0, 4)
			change_sync_stream_volume(0, 5)
		else:
			change_sync_stream_volume(-60, 4)
			change_sync_stream_volume(-60, 5)
	
	last_music_level = music_level


func change_sync_stream_volume(volume: float, id: int) -> void:
	var sub_stream_volume: float = stream.get_sync_stream_volume(id)
	var tween: Tween = create_tween()
	tween.tween_method(set_volume.bind(id), sub_stream_volume, volume, tween_time)

func set_volume(volume: float, id: int) -> void:
	stream.set_sync_stream_volume(id, volume)
