extends CharacterBody2D


@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var rot_amount: float = PI/16
@export var rot_speed: float = 4
@export var move_speed: float = 75
@export var move_lerp: float = 5
@export var stomp_threshold: float = -10
@export var stomp_power: float = 400
@export var hit_percent: float = 20

var move_vel: float
var hit: bool
var car: Car


func _ready() -> void:
	sprite_2d.play("default")


func _physics_process(delta: float) -> void:
	if hit or not is_instance_valid(car): return
	move_vel = lerp(
		move_vel,
		sign(car.position.x - position.x) * move_speed, 
		delta * move_lerp
	)
	velocity.x = move_vel
	velocity += get_gravity()
	move_and_slide()
	
	sprite_2d.rotation = sin(
		Time.get_unix_time_from_system() * rot_speed
	) * rot_amount * abs(velocity.x / move_speed)


func body_entered(body: Node2D) -> void:
	if hit: return
	if body is Car:
		var height_difference: float = body.last_pos.y - position.y
		if height_difference < stomp_threshold:
			body.linear_velocity.y = -stomp_power
			animation_player.play("pressed")
		else:
			body.damage(hit_percent)
			animation_player.play("rammed")
		body.robots_destroyed += 1
		hit = true
