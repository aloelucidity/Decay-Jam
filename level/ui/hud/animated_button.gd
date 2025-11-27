class_name AnimatedButton
extends AnimateGradient


@onready var scroll_container: ScrollContainer = get_node_or_null("ScrollContainer")
@onready var label: Label = get_node_or_null("ScrollContainer/Label")

@export_group("Text")
@export var label_text: String
@export var scroll_wait: float = 5

@export_group("Color")
@export var modulate_self: bool = true
@export var color_tint: Color = Color.DODGER_BLUE
@export var tint_speed: float = 8

@export_group("Floating")
@export var float_speed: float = 1
@export var float_intensity: float = 2
@export var float_offset: float

@export_group("Rotating")
@export var rotate_speed: float = 0.75
@export var rotate_intensity: float = 5

@export_group("Scaling")
@export var scale_speed: float = 6
@export var scale_intensity: float = 1.075

@export_group("Pressing")
@export var click_decay: float = 5
@export var click_intensity: float = 0.2
@export var children_scale_intensity: float = 1.0
@export var click_ease: float = 0.7

var time_offset: float
var hovered: float
var tween: Tween

var base_scale := Vector2.ONE
var override_time: float = 0.0
var initial_position: Vector2

var scroll_timer: float


func _init() -> void:
	variable_id = "texture_normal"
	time_offset = get_instance_id() * 0.468
	connect("mouse_entered", mouse_entered)
	connect("mouse_exited", mouse_exited)
	connect("resized", resized)
	connect("pressed", pressed)
	connect("visibility_changed", visibility_changed)


func _ready() -> void:
	await get_tree().process_frame
	initial_position = position
	resized()
	if label_text != "" and is_instance_valid(label):
		set_text(label_text)


func set_text(text: String) -> void:
	label.text = text
	label.visible = (text.length() > 0) ## to fix a clipping issue


func resized():
	pivot_offset = size / 2
	for child: Control in get_children():
		child.pivot_offset = child.size / 2


func visibility_changed():
	if is_instance_valid(scroll_container):
		scroll_timer = scroll_wait / 2
		scroll_container.scroll_horizontal = 0


func mouse_entered():
	hovered = true
	if is_instance_valid(scroll_container):
		scroll_timer = 0
		scroll_container.scroll_horizontal = 0


func mouse_exited():
	hovered = false


func pressed():
	override_time = 1.0


func _process(delta: float) -> void:
	super(delta)
	
	var unix: float = Time.get_unix_time_from_system()
	position = initial_position
	position.y += sin(time_offset + unix * float_speed) * float_intensity
	position.y -= float_offset
	rotation_degrees = sin(time_offset + unix * rotate_speed) * rotate_intensity
	
	var modulate_var: String = "self_modulate" if modulate_self else "modulate"
	self[modulate_var] = lerp(
		self[modulate_var],
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
	
	if not is_equal_approx(children_scale_intensity, 1.0):
		for child in get_children():
			if not child is TextureRect and not child is TextureProgressBar:
				child.scale = Vector2.ONE + (scale - Vector2.ONE) * children_scale_intensity
	
	if is_instance_valid(scroll_container) and scroll_container.size.x < label.size.x:
		if scroll_timer > 0:
			scroll_timer -= delta
			if scroll_timer <= scroll_wait / 2:
				scroll_container.scroll_horizontal = 0
			if scroll_timer <= 0:
				scroll_timer = 0
		else:
			scroll_container.scroll_horizontal += int(delta * 100)
			var scroll_max: int = int(scroll_container.get_h_scroll_bar().max_value)
			scroll_max -= int(scroll_container.size.x)
			if scroll_container.scroll_horizontal >= scroll_max:
				scroll_container.scroll_horizontal = scroll_max
				scroll_timer = scroll_wait
