extends PlayerInputAction
class_name PlayerInputAnalogAction

enum Axis { X, Y }

enum InputAnalogXAxisState {
	LEFT = -1,
	STATIONARY = 0,
	RIGHT = 1,
}
enum InputAnalogYAxisState {
	UP = -1,
	STATIONARY = 0,
	DOWN = 1,
}

@export var axis: Axis = Axis.X
@export var deadzone: float = 0.25
## action_name = negative direction (left / up)
## secondary_action_name = positive direction (right / down)
@export var secondary_action_name: StringName

var strength: float = 0.0
var direction: int = 0 # cast to InputAnalogXAxisState or InputAnalogYAxisState based on `axis`

func update() -> void:
	var raw_strength: float = Input.get_axis(action_name, secondary_action_name)

	if absf(raw_strength) < deadzone:
		raw_strength = 0.0

	strength = raw_strength
	direction = int(signf(raw_strength))

	var down: bool = raw_strength != 0.0
	if not down:
		state = InputState.RELEASED
	elif state == InputState.RELEASED:
		state = InputState.PRESSED
	else:
		state = InputState.DOWN

func get_x_state() -> InputAnalogXAxisState:
	return direction as InputAnalogXAxisState

func get_y_state() -> InputAnalogYAxisState:
	return direction as InputAnalogYAxisState
