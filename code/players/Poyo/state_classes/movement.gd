extends State
class_name PoyoMovementState

## State that handles basic movement, and basic movement only.

@export var speed: float = 100
@export var acceleration: float = 1000
@export var deceleration: float = 600
@export var turn_acceleration: float = 2000
@export var can_turn: bool = true
@export var turn_sprite: bool = true

var direction: int = 1

func enter():
	var player: Player = target
	var input: PlayerInput = player.input

	if not input:
		return # players probably still initalizing?

	var move: PlayerInputAnalogAction = input.get_input("Move")
	var new_direction: int = move.direction

	if new_direction == 0:
		new_direction = player.direction

	direction = new_direction

	if move.direction != 0:
		start(direction)

func physics_process(delta: float) -> void:
	horizontal_movement(delta)
	vertical_movement(delta)
	target.move_and_slide()

## the direction that the player has started to move in
func start(new_direction: int = 1):
	direction = new_direction

	if not turn_sprite: return
	var player: Player = target

	player.direction = direction

## the player has stopped moving entirely, so this is called. states are meant to expand on this
func stop():
	return

## is the player "turning"? turning in this case is moving in the opposite direction of your momentum
func is_turning() -> bool:
	var player: Player = target

	if player.velocity.x == 0:
		return false

	var input: PlayerInput = target.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var velocity_direction: int = int(signf(player.velocity.x))

	if move.direction == -velocity_direction:
		return true

	return false

## handles horizontal movement
func horizontal_movement(delta: float) -> void:
	var player: Player = target
	var input: PlayerInput = target.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var target_speed: float = speed * move.direction
	var target_acceleration: float = acceleration

	if can_turn and is_turning():
		target_acceleration = turn_acceleration

	if move.direction == 0:
		target_acceleration = deceleration

	if move.direction != 0 and (move.is_pressed() or move.direction != target.direction or move.reversed):
		start(move.direction)

	var was_moving: bool = player.velocity.x != 0

	player.velocity.x = move_toward(player.velocity.x, target_speed, target_acceleration * delta)

	if target_speed == 0 and was_moving and player.velocity.x == 0:
		stop()

## handles vertical movement
func vertical_movement(delta: float) -> void:
	target.gravity(delta)
