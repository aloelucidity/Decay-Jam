class_name Car
extends RigidBody2D


const BODY_OFFSET := Vector2(0, -14)
const BODY_PATH: String = "res://car/bodies/%s.tscn"

@export_group("Nodes")
@export var wheels: Array[Wheel]
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var outage_sound := %Outage
@onready var coin_sound := %Coin

@export_group("Stats")
@export var money: int
@export var multiplier: float = 1000 # times 1000 so i can add to it :P

@export var multiplier_gain: float
@export var rise_multiplier_gain: float

@export var batteries: Array[float]
@export var battery_efficiency: float = 1 ## higher values = less battery usage
@export var battery_efficiency_step: float

@export_group("Physics")
@export var body_stats: BodyStats
@export var wheel_stats: WheelStats
@export var fall_thrust: float
@export var end_speed_threshold: float
@export var end_movement_threshold: float
@export var end_time_threshold: float

@export var coyote_time: float
var coyote_timer: float

var body: Body
var on_ground: bool
var end_timer: float
var last_pos: Vector2
var furthest_distance: float

signal run_ended
signal battery_used


func _ready() -> void:
	collision_shape_2d.shape = body_stats.collision_shape
	collision_shape_2d.position = body_stats.collision_offset + BODY_OFFSET
	
	body = load(BODY_PATH % body_stats.base).instantiate()
	body.position = BODY_OFFSET
	body.car = self
	add_child(body)
	move_child(body, 1)
	
	for wheel in wheels:
		wheel.load_wheel_stats(wheel_stats)
	
	battery_efficiency = 1 + battery_efficiency_step * Globals.battery_efficiency
	batteries.resize(1 + Globals.extra_batteries)
	batteries.fill(100)


func collect_coin(amount: int, stream: AudioStream) -> void:
	money += amount
	
	var pitch_scale: float = snappedf(randf_range(0.25, 1.5), 0.25)
	if is_equal_approx(pitch_scale, 0.75):
		pitch_scale = 0.5
	if is_equal_approx(pitch_scale, 1.25):
		pitch_scale = 1
		
	coin_sound.play()
	coin_sound.get_stream_playback().play_stream(stream, 0, 0, pitch_scale)


func is_on_ground() -> bool:
	for wheel in wheels:
		if wheel.on_ground:
			return true
	return false


func get_total_battery() -> float:
	var total: float = 0
	for battery in batteries:
		total += battery
	return total


func has_battery(amount: float) -> bool:
	if batteries.is_empty(): return false
	
	var usage: float = amount / battery_efficiency
	var total_capacity: float = 0
	for battery in batteries:
		if battery + total_capacity >= usage: 
			return true
		else:
			total_capacity += battery
	
	return false


func use_battery(amount: float) -> void:
	var usage: float = amount / battery_efficiency
	while usage > 0:
		if batteries.size() > 0:
			var power_left: float = batteries[0]
			batteries[0] -= usage
			usage -= power_left
			if batteries[0] <= 0:
				batteries.pop_front()
				emit_signal("battery_used")


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	var last_battery = get_total_battery()
	var delta: float = get_physics_process_delta_time()
	
	on_ground = is_on_ground()
	if on_ground:
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
	
	body.integrate_forces()
	
	if Input.is_action_pressed("move_down") and not on_ground:
		var fall_force := Vector2(0, fall_thrust).rotated(rotation)
		if fall_force.y > 0:
			apply_central_force(fall_force)
	
	if is_zero_approx(round(get_total_battery())) and not is_zero_approx(round(last_battery)):
		outage_sound.play()


func _physics_process(delta: float) -> void:
	var movement: Vector2 = position - last_pos
	var total_speed: float = linear_velocity.length() + abs(angular_velocity)
	
	if position.x > furthest_distance:
		furthest_distance = position.x
		multiplier += movement.x * (multiplier_gain if movement.y >= 0 else rise_multiplier_gain)
	
	var stationary_condition: bool = (
		(movement.length() < end_movement_threshold and on_ground) or 
		total_speed < end_speed_threshold
	) and position.x > 0
	var backwards_condition: bool = round(get_total_battery()) < 1 and linear_velocity.x < 0
	
	if stationary_condition or backwards_condition:
		end_timer -= delta
		if end_timer <= 0:
			emit_signal("run_ended")
			set_process(false)
	else:
		end_timer = end_time_threshold
	
	last_pos = position
