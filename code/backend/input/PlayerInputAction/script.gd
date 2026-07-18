extends Node
class_name PlayerInputAction

enum InputState {
	RELEASED = 0,
	DOWN = 1,
	PRESSED = 2,
	JUST_RELEASED = 3
}

@export var state: InputState = InputState.RELEASED
@export var action_name: StringName = ""

func update():
	var just_pressed: bool = Input.is_action_just_pressed(action_name)
	var down: bool = Input.is_action_pressed(action_name)

	if not down:
		if state != InputState.RELEASED and state != InputState.JUST_RELEASED:
			state = InputState.JUST_RELEASED
		elif state == InputState.JUST_RELEASED:
			state = InputState.RELEASED

		return

	if just_pressed:
		state = InputState.PRESSED
		return

	state = InputState.DOWN

func is_pressed():
	return state == InputState.PRESSED

func is_down():
	return state == InputState.DOWN or state == InputState.PRESSED

func is_released():
	return state == InputState.RELEASED or state == InputState.JUST_RELEASED

func is_just_released():
	return state == InputState.JUST_RELEASED
