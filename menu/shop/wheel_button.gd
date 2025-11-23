class_name WheelButton
extends AnimatedButton


const PRICE_SUFFIX: String = "[$%s]"
const OWNED_SUFFIX: String = "[Owned]"
const EQUIPPED_SUFFIX: String = "[Equipped]"

const BEVEL_STRENGTH: float = 0.75
const TOO_EXPENSIVE_STRENGTH: float = 0.35

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var shadow: AnimatedSprite2D = %Shadow
@onready var sprite_bg: TextureRect = %SpriteBG
@onready var label: Label = %Label
@export var wheel_stats: WheelStats
@export var too_expensive_color: Color


func _ready() -> void:
	load_wheel_stats()
	
	material = material.duplicate()
	sprite_bg.connect("resized", bg_resized)
	bg_resized()
	
	Globals.connect("wheel_equipped", wheel_equipped)
	wheel_equipped(Globals.equipped_wheel)
	
	Globals.connect("body_equipped", update_visuals)


func load_wheel_stats():
	sprite.sprite_frames = wheel_stats.frames
	shadow.sprite_frames = sprite.sprite_frames


func pressed():
	super()
	
	if wheel_stats in Globals.owned_wheels:
		Globals.equipped_wheel = wheel_stats
		
	elif Globals.money >= wheel_stats.shop_cost:
		Globals.money -= wheel_stats.shop_cost
		Globals.owned_wheels.append(wheel_stats)
		Globals.equipped_wheel = wheel_stats


func bg_resized():
	sprite.position = sprite_bg.size / 2


func wheel_equipped(wheel: WheelStats):
	set_pressed_no_signal(wheel == wheel_stats)
	update_visuals()


func update_visuals(_equipped = null):
	label.text = wheel_stats.shop_name
	label.text += "\n"
	if button_pressed:
		label.text += EQUIPPED_SUFFIX
	elif wheel_stats in Globals.owned_wheels:
		label.text += OWNED_SUFFIX
	else:
		label.text += PRICE_SUFFIX % wheel_stats.shop_cost
		if wheel_stats.shop_cost > Globals.money:
			modulate = too_expensive_color
			disabled = true
		else:
			modulate = Color.WHITE
			disabled = false
	
	var strength_sign: float = -1 if button_pressed else 1
	material.set_shader_parameter(
		"strength", 
		TOO_EXPENSIVE_STRENGTH if disabled else BEVEL_STRENGTH * strength_sign
	)
