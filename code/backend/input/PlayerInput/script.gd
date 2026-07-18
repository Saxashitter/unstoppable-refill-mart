extends Node
class_name PlayerInput

# simple movement keys
@export var actions: Dictionary[String, PlayerInputAction] = {}

func _ready():
	for action in get_children():
		if action is not PlayerInputAction: continue
		actions[action.name] = action

func _physics_process(delta: float):
	if not is_multiplayer_authority(): return # TODO: maybe work on a net-synched multiplayer input solution?

	for action_key in actions.keys():
		var action: PlayerInputAction = actions[action_key]

		action.update()

func get_input(string: String) -> PlayerInputAction:
	return actions[string]
