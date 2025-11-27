extends Node


const KEYBOARD_SECTION: String = "Keyboard Bindings"
const CONTROLLER_SECTION: String = "Controller Bindings"
const DEADZONE: float = 0.5


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


func apply_bindings(bindings: Array[ControlBinding], action_name: String) -> void:
	InputMap.erase_action(action_name)
	InputMap.add_action(action_name)
	for binding in bindings:
		InputMap.action_add_event(action_name, binding.get_input_event())
