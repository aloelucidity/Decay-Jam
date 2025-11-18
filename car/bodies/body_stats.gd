class_name BodyStats
extends Resource


@export var base: String
@export var collision_shape: Shape2D
@export var collision_offset: Vector2

@export var armor: float = 1
@export var drag: float = 15
@export var drag_threshold: float = 800

@export var modifiers: Dictionary[StringName, Variant]
