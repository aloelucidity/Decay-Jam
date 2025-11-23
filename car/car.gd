class_name Car
extends RigidBody2D


const BODY_OFFSET := Vector2(0, -14)
const BODY_PATH: String = "res://car/bodies/scenes/%s.tscn"

enum CarStat {
	Fragments,
	Robots,
	Distance,
	Ascent
}

@export var ending_path: String

@export_group("Nodes")
@export var joints: Array[PinJoint2D]
@export var wheels: Array[Wheel]
@export var wheel_casts: Array[RayCast2D]
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var outage_sound := %Outage
@onready var coin_sound := %Coin
@onready var static_rect: ColorRect = %Static
@onready var camera_2d: Camera2D = %Camera2D
@onready var level_generator: LevelGenerator = %LevelGenerator


@export_group("Stats")
@export var fragments_collected: int
@export var robots_destroyed: int
@export var distance_traveled: float
@export var distance_ascended: float

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
	body_stats = Globals.equipped_body
	wheel_stats = Globals.equipped_wheel
	
	collision_shape_2d.shape = body_stats.collision_shape
	collision_shape_2d.position = body_stats.collision_offset + BODY_OFFSET
	
	body = load(BODY_PATH % body_stats.base).instantiate()
	body.position = BODY_OFFSET
	body.car = self
	add_child(body)
	move_child(body, 1)
	
	for joint in joints:
		joint.position.x = sign(joint.position.x) * (body_stats.wheel_spacing/2)
		joint.position += wheel_stats.offset
		joint.disable_collision = !joint.disable_collision
		joint.disable_collision = !joint.disable_collision
	
	for wheel in wheels:
		wheel.load_wheel_stats(wheel_stats)
	
	battery_efficiency = 1 + battery_efficiency_step * Globals.battery_efficiency
	batteries.resize(1 + Globals.extra_batteries)
	batteries.fill(100)


func collect_coin(amount: int, stream: AudioStream) -> void:
	fragments_collected += amount
	
	var pitch_scale: float = snappedf(randf_range(0.25, 1.5), 0.25)
	if is_equal_approx(pitch_scale, 0.75):
		pitch_scale = 0.5
	if is_equal_approx(pitch_scale, 1.25):
		pitch_scale = 1
		
	coin_sound.play()
	coin_sound.get_stream_playback().play_stream(stream, 0, 0, pitch_scale)


func damage(hit_percent: float) -> void:
	hit_percent /= body_stats.armor
	hit_percent = min(hit_percent, get_total_battery() - 0.01)
	use_battery(hit_percent)
	
	static_rect.noise_intensity = max(0.15, hit_percent / 200)
	camera_2d.shake_intensity = max(4, hit_percent / 5)
	linear_velocity /= 1 + (hit_percent / 80 / body_stats.armor)


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
	var colliding_casts: int = 0
	for cast: RayCast2D in wheel_casts:
		cast.position.y = -linear_velocity.y / 200
		cast.rotation = -rotation / 4
		if cast.is_colliding():
			colliding_casts += 1
	
	var collide_one_ways: bool = colliding_casts >= wheel_casts.size()
	collision_mask = 1 if not collide_one_ways else 5
	for wheel: Wheel in wheels:
		wheel.collision_mask = 1 if not collide_one_ways else 5
	
	if position.x < -level_generator.base_slope_length + 20:
		linear_velocity.x = 100
	if position.x > level_generator.level_length + 16 or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Transitions.change_scene_to(ending_path)
	
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
		distance_traveled += movement.x
		if movement.y < 0:
			distance_ascended += movement.x
	
	var stationary_condition: bool = (
		(movement.length() < end_movement_threshold and on_ground) or 
		total_speed < end_speed_threshold
	) and position.x > 0
	var backwards_condition: bool = round(get_total_battery()) < 1 and linear_velocity.x < 0
	
	if stationary_condition or backwards_condition:
		end_timer -= delta
		if end_timer <= 0:
			emit_signal("run_ended")
	else:
		end_timer = end_time_threshold
	
	last_pos = position
