extends Node
class_name StateMachine

@export var target: Node2D

var states: Dictionary[String, State]
var current_state: State

func set_state(state: State):
	if current_state:
		current_state.exit()

	current_state = state
	state.enter()

func set_state_by_name(state_name: String):
	if states[state_name] == null: return

	var state: State = states[state_name]
	set_state(state)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get all states and all to states dictionary
	for state in get_children():
		if state is not State: continue

		state.machine = self
		state.states = states
		state.target = target
		states[state.name] = state

	var first_state: State = get_child(0)
	set_state(first_state)

func _process(delta: float):
	if current_state == null: return
	current_state.process(delta)

func _physics_process(delta: float):
	if current_state == null: return
	current_state.physics_process(delta)
