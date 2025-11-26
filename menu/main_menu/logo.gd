extends TextureRect


@export var bob_speed: float
@export var bob_strength: float

@export var rot_speed: float
@export var rot_strength: float

var initial_pos: Vector2


func _ready() -> void:
	await get_tree().process_frame
	initial_pos = position
	pivot_offset = size / 2


func _process(_delta: float) -> void:
	position.y = initial_pos.y + sin(Time.get_unix_time_from_system() * bob_speed) * bob_strength
	rotation = sin(Time.get_unix_time_from_system() * rot_speed) * rot_strength
