extends Sprite2D


@onready var wheels: Array[AnimatedSprite2D] = [
	$Wheel1,
	$Wheel2
]


func _ready() -> void:
	var body_stats: BodyStats = Globals.equipped_body
	var wheel_stats: WheelStats = Globals.equipped_wheel
	
	texture = body_stats.shop_sprite
	offset = body_stats.ending_offset
	position -= offset
	
	for wheel: AnimatedSprite2D in wheels:
		wheel.show_behind_parent = body_stats.wheels_behind
		wheel.position.x = body_stats.wheel_spacing/2 * sign(wheel.position.x)
		wheel.sprite_frames = wheel_stats.frames
