extends Node
class_name State

var machine: StateMachine
var states: Dictionary[String, State] = {}

## Called upon entering the state in StateMachine.
func enter(_parent): pass

## When the state updates.
func process(_parent, _delta: float): pass

## When the physics update.
func physics_process(_parent, _delta: float): pass

## Called upon exiting the state and moving to another in StateMachine.
func exit(_parent): pass

## Return the next state when this state should change.
func should(_parent) -> Variant: return null

## Optional helper for physics-driven transitions.
func post(_parent, _delta: float) -> Variant: return null
