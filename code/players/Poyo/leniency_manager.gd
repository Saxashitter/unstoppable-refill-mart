extends Node
class_name LeniencyManager

## basic manager helper for cross-state jump leniency

@export var player: Player
@export var jump_leniency_time: float = 0.25

var timer: float = jump_leniency_time

func update(delta: float):
	if player.is_on_floor():
		timer = jump_leniency_time
		return

	timer = max(0, timer - delta)

func can_jump() -> bool:
	return timer > 0

func reset() -> void:
	timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
