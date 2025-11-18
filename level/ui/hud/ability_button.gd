extends AnimateGradient


@export var color_tint: Color = Color.DODGER_BLUE
@export var tint_speed: float = 8

@export var float_speed: float = 1
@export var float_intensity: float = 2

@export var rotate_speed: float = 0.75
@export var rotate_intensity: float = 5

@export var scale_speed: float = 6
@export var scale_intensity: float = 1.075

@export var click_decay: float = 5
@export var click_intensity: float = 0.2
@export var click_ease: float = 0.7

var time_offset: float
var hovered: float
var tween: Tween

var base_scale := Vector2.ONE
var override_time: float = 0.0


func _init() -> void:
	variable_id = "texture_normal"
	time_offset = get_instance_id() * 0.468
	connect("mouse_entered", mouse_entered)
	connect("mouse_exited", mouse_exited)
	connect("resized", resized)
	connect("pressed", pressed)


func resized():
	pivot_offset = size / 2


func mouse_entered():
	hovered = true


func mouse_exited():
	hovered = false


func pressed():
	override_time = 1.0


func _process(delta: float) -> void:
	super(delta)
	
	var unix: float = Time.get_unix_time_from_system()
	position.y = sin(time_offset + unix * float_speed) * float_intensity
	rotation_degrees = sin(time_offset + unix * rotate_speed) * rotate_intensity
	
	modulate = lerp(
		modulate, 
		color_tint if hovered else Color.WHITE, 
		delta * tint_speed
	)
	
	var target_scale: Vector2 = Vector2.ONE
	if hovered:
		target_scale = Vector2(scale_intensity, scale_intensity)
	
	if override_time > 0.0:
		var override_intensity: float = ease(override_time, click_ease) * click_intensity
		var override_scale := base_scale + Vector2(override_intensity, override_intensity)
		scale = override_scale
		override_time -= delta * click_decay
	else:
		base_scale = lerp(
			base_scale, 
			target_scale, 
			delta * scale_speed
		)
		scale = base_scale
