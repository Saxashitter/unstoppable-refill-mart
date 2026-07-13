extends Node
class_name State

var target: Player # TODO: find a way to generalize this

var machine: StateMachine
var states: Dictionary[String, State]

func enter(): pass
func process(delta: float): pass
func physics_process(delta: float): pass
func exit(): pass
func could() -> bool: return true
