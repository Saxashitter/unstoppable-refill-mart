extends Node
class_name StateMachine

var current_state: State
var states: Dictionary[String, State] = {}
@export var initial_state: String = ""

func set_state(state: State) -> void:
	if state == null:
		return
	if current_state == state:
		return

	print("Setting state to: %s" % state.name)
	if current_state != null:
		current_state.exit(get_parent())

	current_state = state
	current_state.enter(get_parent())

func call_state_func(function_name: String, args: Array = []) -> void:
	if current_state == null:
		return

	var call_args: Array = args.duplicate()
	call_args.push_front(get_parent())

	var result = current_state.callv(function_name, call_args)
	if result == null:
		return

	if result is State:
		set_state(result)
		return

	if result is String and states.has(result):
		set_state(states[result])

func _ready() -> void:
	var first_state: State = null
	for child in get_children():
		if child is State:
			if first_state == null:
				first_state = child
			child.machine = self
			child.states = states
			states[child.name] = child

	if initial_state != "" and states.has(initial_state):
		set_state(states[initial_state])
	elif first_state != null:
		set_state(first_state)

func _process(delta: float) -> void:
	call_state_func("process", [delta])

func _physics_process(delta: float) -> void:
	call_state_func("physics_process", [delta])
	call_state_func("should")
