extends Node
class_name PlayerInputAction

enum InputState {
	RELEASED = 0,
	DOWN = 1,
	PRESSED = 2
}

@export var state: InputState = InputState.RELEASED
@export var action_name: StringName = ""

func update():
	var just_pressed: bool = Input.is_action_just_pressed(action_name)
	var down: bool = Input.is_action_pressed(action_name)

	if not down:
		state = InputState.RELEASED
		return

	if just_pressed:
		state = InputState.PRESSED
		return

	state = InputState.DOWN

func is_pressed():
	return state == InputState.PRESSED

func is_down():
	return state >= InputState.DOWN

func is_released():
	return state == InputState.RELEASED
