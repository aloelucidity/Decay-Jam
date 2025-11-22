extends Sprite2D

## custom parallax implementation as official one
## works in a buggy way with my method of zooming

@export var camera: Camera2D
@export var parallax_offset: Vector2
@export var parallax_scale := Vector2.ONE
@export var repeat: float
@export var min_y_offset: float
var mirror: Sprite2D


func _ready() -> void:
	mirror = duplicate()
	mirror.set_script(null)
	mirror.position = Vector2(repeat, 0)
	mirror.scale = Vector2.ONE
	add_child(mirror)


func _process(_delta: float) -> void:
	var cam_pos: Vector2 = camera.get_screen_center_position()
	position = cam_pos * parallax_scale
	
	## looping
	var difference: float = position.x - cam_pos.x
	difference = fmod(difference, repeat*scale.x)
	position.x = cam_pos.x + difference
	
	position += parallax_offset
	position.y = max(position.y, cam_pos.y + min_y_offset)
