class_name Car
extends RigidBody2D


@export_group("Nodes")
@export var wheels: Array[Wheel]
@onready var jump_sound := %Jump
@onready var outage_sound := %Outage
@onready var coin_sound := %Coin

@export_group("Stats")
@export var money: int
@export var multiplier: float = 1000 # times 1000 so i can add to it :P

@export var multiplier_gain: float
@export var rise_multiplier_gain: float

@export var batteries: Array[float] = [100]
@export var battery_efficiency: float = 1 ## higher values = less battery usage

@export_group("Physics")
@export var wheel_torque: float
@export var wheel_energy: float

@export var jump_impulse: float
@export var jump_energy: float
@export var jump_cancel_multiplier: float = 1

@export var fall_thrust: float

@export var can_hover: bool
@export var hover_thrust: float
@export var hover_rot_speed: float
@export_range(0, 360, 0.1, "radians_as_degrees") var hover_rotation: float
@export var hover_energy: float

@export var end_speed_threshold: float
@export var end_movement_threshold: float
@export var end_time_threshold: float

var on_ground: bool
var end_timer: float
var last_pos: Vector2
var furthest_distance: float

@export var coyote_time: float
var coyote_timer: float
var jump_cancelled: bool

signal run_ended


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


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	var last_battery = get_total_battery()
	var delta: float = get_physics_process_delta_time()
	
	on_ground = is_on_ground()
	if on_ground:
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("move_up") and coyote_timer > 0 and has_battery(jump_energy):
		angular_velocity = 0
		apply_central_impulse(Vector2(0, -jump_impulse).rotated(rotation))
		use_battery(jump_energy)
		jump_sound.play()
		jump_cancelled = false
	
	if not on_ground and not jump_cancelled and not Input.is_action_pressed("move_up"):
		linear_velocity.y *= jump_cancel_multiplier
		jump_cancelled = true
	
	if Input.is_action_pressed("move_down") and not on_ground:
		var fall_force := Vector2(0, fall_thrust).rotated(rotation)
		if fall_force.y > 0:
			apply_central_force(fall_force)
	
	var direction: float = Input.get_axis("move_left", "move_right")
	if Input.is_action_pressed("move_up") and not on_ground and has_battery(hover_energy) and can_hover:
		if linear_velocity.y > -hover_thrust * delta:
			apply_central_impulse(Vector2(0, -hover_thrust).rotated(rotation))
			use_battery(hover_energy)
		
		var target_rot: float = hover_rotation * direction
		rotation = lerp_angle(rotation, target_rot, delta * hover_rot_speed)
	
	if is_zero_approx(round(get_total_battery())) and not is_zero_approx(round(last_battery)):
		outage_sound.play()


func _physics_process(delta: float) -> void:
	var movement: Vector2 = position - last_pos
	var total_speed: float = linear_velocity.length() + abs(angular_velocity)
	
	if position.x > furthest_distance:
		furthest_distance = position.x
		multiplier += movement.x * (multiplier_gain if movement.y >= 0 else rise_multiplier_gain)
	
	var stationary_condition: bool = (
		movement.length() < end_movement_threshold or total_speed < end_speed_threshold 
	) and on_ground
	var backwards_condition: bool = round(get_total_battery()) < 1 and linear_velocity.x < 0
	
	if stationary_condition or backwards_condition:
		end_timer -= delta
		if end_timer <= 0:
			emit_signal("run_ended")
			set_process(false)
	else:
		end_timer = end_time_threshold
	
	last_pos = position
