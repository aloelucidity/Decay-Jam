class_name KeybindUI
extends VBoxContainer


const LISTENING_TEXT: String = "Press..."


@onready var label: Label = $Label
@onready var button: AnimatedButton = $MarginContainer/Button
@onready var clear_progress: TextureProgressBar = %ClearProgress
@onready var hold_timer: Timer = $HoldTimer
@export var action_name: String
@export var label_text: String
@export var button_press_threshold: float = 0.2

var hold_tween: Tween
var is_controller: bool
var is_listening: bool


func _ready() -> void:
	label.text = label_text
	button.connect("button_down", button_down)
	button.connect("button_up", button_up)
	load_bindings(ControlManager.get_bindings(action_name, is_controller))


func change_controller_mode(new_is_controller: bool) -> void:
	is_controller = new_is_controller
	load_bindings(ControlManager.get_bindings(action_name, is_controller))


func load_bindings(bindings: Array[ControlBinding]) -> void:
	var text: String = ""
	for binding in bindings:
		if text != "":
			text += ", "
		text += binding.get_human_name()
	button.set_text(text)


func clear_bindings() -> void:
	ControlManager.set_bindings([], action_name, is_controller)
	load_bindings([])
	
	if is_instance_valid(hold_tween):
		hold_tween.stop()
		hold_tween = null
	
	button.override_time = 1.0 ## to make it look as if it was pressed
	clear_progress.value = 0
	hold_timer.stop()


func button_down() -> void:
	var hold_time: float = hold_timer.wait_time
	hold_tween = create_tween()
	hold_tween.tween_property(clear_progress, "value", 1.0, hold_time - button_press_threshold).set_delay(button_press_threshold)
	hold_tween.connect("finished", clear_bindings)
	hold_tween.play()
	hold_timer.start()


func button_up() -> void:
	if hold_timer.time_left >= hold_timer.wait_time - button_press_threshold:
		start_listening()
	
	if is_instance_valid(hold_tween):
		hold_tween.stop()
		hold_tween = null
	
	clear_progress.value = 0
	hold_timer.stop()


func start_listening() -> void:
	is_listening = true
	button.set_text(LISTENING_TEXT)


func _input(event: InputEvent) -> void:
	if not is_listening: return
	if not event.is_pressed(): return
	if is_controller and not event.get_class() in ControlManager.ACCEPTED_CONTROLLER: return
	if not is_controller and not event.get_class() in ControlManager.ACCEPTED_KEYBOARD: return
	if event is InputEventJoypadMotion and abs(event.axis_value) < ControlManager.DEADZONE: return
	
	is_listening = false
	
	var bindings: Array[ControlBinding] = ControlManager.get_bindings(action_name, is_controller)
	var new_binding := ControlBinding.new()
	new_binding.load_input_event(event)
	
	var matching_found: bool
	for binding in bindings:
		if new_binding.save_raw_data().hash() == binding.save_raw_data().hash():
			bindings.erase(binding)
			matching_found = true
	
	if not matching_found:
		bindings.append(new_binding)
	
	ControlManager.set_bindings(bindings, action_name, is_controller)
	load_bindings(bindings)
	get_viewport().set_input_as_handled()
