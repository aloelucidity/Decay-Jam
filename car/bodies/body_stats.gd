class_name BodyStats
extends Resource


@export var base: String
@export var wheel_spacing: float = 24
@export var collision_shape: Shape2D
@export var collision_offset: Vector2

@export var armor: float = 1
@export var damp: float = 0.1
@export var resistance: float = 0.3
@export var resistance_threshold: float = 800
@export var light_divider: float = 1

@export_group("Shop")
@export var shop_name: String
@export_multiline var shop_description: String
@export var shop_cost: int
@export var shop_sprite: Texture
