class_name BodyButton
extends AnimatedButton


const PRICE_SUFFIX: String = "[$%s]"
const OWNED_SUFFIX: String = "[Owned]"
const EQUIPPED_SUFFIX: String = "[Equipped]"

const BEVEL_STRENGTH: float = 0.75
const TOO_EXPENSIVE_STRENGTH: float = 0.35

@onready var sprite: Sprite2D = %Sprite
@onready var shadow: Sprite2D = %Shadow
@onready var sprite_bg: TextureRect = %SpriteBG
@onready var label: Label = %Label
@export var body_stats: BodyStats
@export var too_expensive_color: Color


func _ready() -> void:
	load_body_stats()
	
	material = material.duplicate()
	sprite_bg.connect("resized", bg_resized)
	bg_resized()
	
	Globals.connect("body_equipped", body_equipped)
	body_equipped(Globals.equipped_body)
	
	Globals.connect("wheel_equipped", update_visuals)


func load_body_stats():
	sprite.texture = body_stats.shop_sprite
	shadow.texture = sprite.texture


func pressed():
	super()
	
	if body_stats in Globals.owned_bodies:
		Globals.equipped_body = body_stats
		
	elif Globals.money >= body_stats.shop_cost:
		Globals.money -= body_stats.shop_cost
		Globals.owned_bodies.append(body_stats)
		Globals.equipped_body = body_stats


func bg_resized():
	sprite.position = sprite_bg.size / 2


func body_equipped(body: BodyStats):
	set_pressed_no_signal(body == body_stats)
	update_visuals()


func update_visuals(_equipped = null):
	label.text = body_stats.shop_name
	label.text += "\n"
	if button_pressed:
		label.text += EQUIPPED_SUFFIX
	elif body_stats in Globals.owned_bodies:
		label.text += OWNED_SUFFIX
	else:
		label.text += PRICE_SUFFIX % body_stats.shop_cost
		if body_stats.shop_cost > Globals.money:
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
