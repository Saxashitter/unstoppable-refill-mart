extends PoyoMovementState
class_name PoyoSkidState

## when you let go of the dash key, or when you turn around, you go into this transition state

@export var dash_state: PoyoDashState
@export var base_state: PoyoBaseState
@export var jump_state: PoyoDashJumpState
@export var leniency_manager: LeniencyManager

func enter():
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	animator.play("skid")
	dash_state.enable_rail_grinding(false)

func physics_process(delta: float) -> void:
	leniency_manager.update(delta)
	super(delta)

func horizontal_movement(delta: float) -> void:
	var player: Player = target
	var input: PlayerInput = player.input
	var jump: PlayerInputAction = input.get_input("Jump")

	player.velocity.x = move_toward(player.velocity.x, 0, deceleration * delta)

	if jump.is_pressed():
		var _jump_height: float = jump_state.jump_height

		player.direction *= -1
		player.velocity.x = dash_state.speed * player.direction
		jump_state.jump_height *= 1.25

		machine.set_state(jump_state)

		player.animator.play("Spinjump")
		jump_state.jump_descending = true
		jump_state.jump_height = _jump_height

		return

	if player.velocity.x == 0 and player.is_on_floor():
		var sprint: PlayerInputAction = input.get_input("Sprint")

		if not sprint.is_down():
			machine.set_state(base_state)
			return

		player.direction *= -1 # REVERSE!!!! 180 DEGREES BABY!!!
		dash_state.dash_on_start = false
		machine.set_state(dash_state)
