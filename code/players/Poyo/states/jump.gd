extends PoyoAirState
class_name PoyoJumpState

## the air state, but for jumps

@export var jump_height: float = 420
@export var leniency_manager: LeniencyManager

var jump_halved: bool = false
var jump_descending: bool = false

func enter():
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	jump_halved = false
	jump_descending = false

	player.velocity.y = -jump_height

	animator.speed_scale = 1
	animator.play("jump")

	leniency_manager.reset()

func half_jump():
	var player: Player = target

	jump_halved = true
	if player.velocity.y < 0: player.velocity.y /= 2

func jump_descent():
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	jump_descending = true

	animator.speed_scale = 1
	animator.play("fall")

func physics_process(delta: float) -> void:
	var player: Player = target
	var input: PlayerInput = player.input
	var jump: PlayerInputAction = input.get_input("Jump")

	if not jump.is_down() and not jump_halved:
		half_jump()

	if player.velocity.y >= 0 and not jump_descending:
		jump_descent()

	super(delta)

func safe_jump() -> bool:
	var player: Player = target
	var machine: StateMachine = player.state_machine
	var input: PlayerInput = player.input
	var jump: PlayerInputAction = input.get_input("Jump")

	if jump.is_pressed() and leniency_manager.can_jump():
		machine.set_state(self)
		return true

	return false
