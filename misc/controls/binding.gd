class_name ControlBinding
extends Resource


enum InputType {
	Keyboard,
	Mouse,
	JoypadButton,
	JoypadMotion
}

var input_type: InputType
## keycode for keyboard, button index for mouse and controller,
## axis for joystick/triggers
var input_value: int
## joystick/triggers only
var axis_sign: int


func load_input_event(event: InputEvent) -> void:
	match event.get_class():
		"InputEventKey":
			input_type = InputType.Keyboard
			input_value = (event as InputEventKey).keycode
		"InputEventMouseButton":
			input_type = InputType.Mouse
			input_value = (event as InputEventMouseButton).button_index
		"InputEventJoypadButton":
			input_type = InputType.JoypadButton
			input_value = (event as InputEventJoypadButton).button_index
		"InputEventJoypadMotion":
			input_type = InputType.JoypadMotion
			input_value = (event as InputEventJoypadMotion).axis
			axis_sign = sign((event as InputEventJoypadMotion).axis_value)


func load_raw_data(raw_data: Dictionary) -> void:
	input_type = raw_data.get("input_type", InputType.Keyboard)
	input_value = raw_data.get("input_value", 0)
	axis_sign = raw_data.get("axis_sign", 1)


func save_raw_data() -> Dictionary:
	var raw_data: Dictionary = {
		"input_type": input_type,
		"input_value": input_value
	}
	if input_type == InputType.JoypadMotion:
		raw_data.set("axis_sign", axis_sign)
	
	return raw_data


func get_input_event() -> InputEvent:
	match input_type:
		InputType.Keyboard:
			var input_event := InputEventKey.new()
			input_event.keycode = input_value as Key
			return input_event
		InputType.Mouse:
			var input_event := InputEventMouseButton.new()
			input_event.button_index = input_value as MouseButton
			return input_event
		InputType.JoypadButton:
			var input_event := InputEventJoypadButton.new()
			input_event.button_index = input_value as JoyButton
			return input_event
		InputType.JoypadMotion:
			var input_event := InputEventJoypadMotion.new()
			input_event.axis = input_value as JoyAxis
			input_event.axis_value = float(axis_sign)
			return input_event
	return null


## For getting human-readable names from button_index variables.
const UNKNOWN: String = "Unknown"
const MOUSE_BUTTONS: Array = [
	UNKNOWN,
	"Left Click",
	"Right Click",
	"Middle Click",
	"Wheel Up",
	"Wheel Down",
	"Wheel Left",
	"Wheel Right",
	"Click 4",
	"Click 5"
]
const JOY_BUTTONS: Array = [
	"A",
	"B",
	"X",
	"Y",
	"LB",
	"RB",
	"LT",
	"RT",
	"LS",
	"RS",
	"Select",
	"Start",
	"Up",
	"Down",
	"Left",
	"Right",
	"Logo",
	"Misc",
	"Paddle 1",
	"Paddle 2",
	"Paddle 3",
	"Paddle 4",
	"Touchpad"
]
const JOY_AXES: Array = [
	"Left Stick X",
	"Left Stick Y",
	"Right Stick X",
	"Right Stick Y",
	"Left Trigger",
	"Right Trigger"
]

func get_human_name() -> String:
	match input_type:
		InputType.Keyboard:
			return OS.get_keycode_string(input_value)
		InputType.Mouse:
			if input_value < MOUSE_BUTTONS.size():
				return MOUSE_BUTTONS[input_value]
			return UNKNOWN
		InputType.JoypadButton:
			if input_value < JOY_BUTTONS.size():
				return JOY_BUTTONS[input_value]
			return UNKNOWN
		InputType.JoypadMotion:
			var axis_string: String = UNKNOWN
			if input_value < JOY_AXES.size():
				axis_string = JOY_AXES[input_value]
			return axis_string + "-" if axis_sign < 0 else "+"
	return UNKNOWN
