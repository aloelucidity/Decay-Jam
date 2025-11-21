class_name WheelStats
extends Resource


@export var torque: float
@export var energy_usage: float
@export var physics_material: PhysicsMaterial

@export var size: float
@export var offset: Vector2
@export var frames: SpriteFrames

@export_group("Shop")
@export var shop_name: String
@export_multiline var shop_description: String
@export var shop_cost: int
