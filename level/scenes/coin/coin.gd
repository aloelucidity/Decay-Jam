extends Area2D


var car: Car

@onready var sprite: AnimatedSprite2D = %Sprite
@export var stream: AudioStream
@export var magnet_speed: float = 1.5
@export var money_amount: int = 1


func _ready() -> void:
	sprite.play("default")


func body_entered(body: Node2D) -> void:
	if body is Car:
		car = body


func body_exited(body: Node2D) -> void:
	if body == car:
		car = null


func _physics_process(delta: float) -> void:
	if not is_instance_valid(car): return
	position = position.lerp(car.position, delta * magnet_speed)


func collect_body_entered(body: Node2D) -> void:
	if body is Car:
		body.collect_coin(money_amount, stream)
		queue_free()
