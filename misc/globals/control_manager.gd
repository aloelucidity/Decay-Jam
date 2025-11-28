extends Node


const KEYBOARD_SECTION: String = "Keyboard Bindings"
const CONTROLLER_SECTION: String = "Controller Bindings"
const ACCEPTED_KEYBOARD: Array[String] = [
	"InputEventKey",
	"InputEventMouseButton"
]
const ACCEPTED_CONTROLLER: Array[String] = [
	"InputEventJoypadButton",
	"InputEventJoypadMotion"
]
const DEADZONE: float = 0.5


func _ready() -> void:
	var controller_keys: PackedStringArray = LocalSettings.get_section_keys(CONTROLLER_SECTION)
	var keyboard_keys: PackedStringArray = LocalSettings.get_section_keys(KEYBOARD_SECTION)
	
	for controller_key in controller_keys:
		var bindings: Array[ControlBinding] = get_bindings(controller_key, true)
		apply_bindings(bindings, controller_key, true)

	for keyboard_key in keyboard_keys:
		var bindings: Array[ControlBinding] = get_bindings(keyboard_key, false)
		apply_bindings(bindings, keyboard_key, false)


func get_bindings(action_name: String, is_controller: bool) -> Array[ControlBinding]:
	var section: String = CONTROLLER_SECTION if is_controller else KEYBOARD_SECTION
	var raw_bindings: Array[Dictionary] = LocalSettings.load_setting(section, action_name, [] as Array[Dictionary])
	
	var bindings: Array[ControlBinding]
	for raw_binding in raw_bindings:
		var binding := ControlBinding.new()
		binding.load_raw_data(raw_binding)
		bindings.append(binding)
	return bindings


func set_bindings(bindings: Array[ControlBinding], action_name: String, is_controller: bool) -> void:
	var section: String = CONTROLLER_SECTION if is_controller else KEYBOARD_SECTION
	var serialized_bindings: Array[Dictionary]
	for binding in bindings:
		serialized_bindings.append(binding.save_raw_data())
	LocalSettings.change_setting(section, action_name, serialized_bindings)
	apply_bindings(bindings, action_name, is_controller)


func apply_bindings(bindings: Array[ControlBinding], action_name: String, is_controller: bool) -> void:
	if InputMap.has_action(action_name):
		var event_removal_queue: Array[InputEvent]
		for event: InputEvent in InputMap.action_get_events(action_name):
			if is_controller and event.get_class() in ACCEPTED_CONTROLLER:
				event_removal_queue.append(event)
			elif not is_controller and event.get_class() in ACCEPTED_KEYBOARD:
				event_removal_queue.append(event)
		
		for event: InputEvent in event_removal_queue:
			InputMap.action_erase_event(action_name, event)
	else:
		InputMap.add_action(action_name)
	
	for binding in bindings:
		InputMap.action_add_event(action_name, binding.get_input_event())
