extends Node
class_name State

var target: Node2D # TODO: find a way to generalize this

var machine: StateMachine
var states: Dictionary[String, State]

func enter(): pass
func process(delta: float): pass
func physics_process(delta: float): pass
func exit(): pass
func could() -> bool: return true
func safe_set(on_set: Callable = func(): pass) -> bool:
	if not could(): return false

	on_set.call()
	machine.set_state(self)
	return true
