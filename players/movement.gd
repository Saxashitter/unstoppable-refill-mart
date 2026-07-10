extends Node
class_name Movement

var gravity_multiplier: float = 1
var friction_multiplier: float = 1

var friction: float = 500

func input_direction() -> int:
	var dir: int = 0

	if Input.is_action_pressed("left"):
		dir -= 1

	if Input.is_action_pressed("right"):
		dir += 1

	return dir

func apply_gravity(character: Player, delta: float) -> void:
	character.velocity += character.get_gravity() * gravity_multiplier * delta

	# reset
	gravity_multiplier = 1

func apply_friction(character: Player, delta: float) -> void:
	character.velocity.x = move_toward(
		character.velocity.x,
		0,
		friction * friction_multiplier * delta
	)

	# reset
	friction_multiplier = 1
