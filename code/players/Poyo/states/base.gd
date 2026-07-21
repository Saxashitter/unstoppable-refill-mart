extends PoyoMovementState
class_name PoyoBaseState

## poyos regular movement state

@export var leniency_manager: LeniencyManager
@export var jump_state: PoyoJumpState
@export var air_state: PoyoAirState
@export var dash_state: PoyoDashState

func enter():
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	if not player.animator: return

	player.camera.state_machine.set_state_by_name("Base")

	if player.velocity.x != 0:
		animator.play("walk")
	else:
		animator.speed_scale = 1
		animator.play("idle")

	super()

func physics_process(delta: float) -> void:
	super(delta)

	var player: Player = target
	var input: PlayerInput = player.input
	var sprint: PlayerInputAction = input.get_input("Sprint")

	player.effects.ghost_effect()

	leniency_manager.update(delta)

	if air_state.safe_fall(): return
	if jump_state.safe_jump(): return

	if sprint.is_down():
		dash_state.dash_on_start = true
		machine.set_state(dash_state)
		return

func _process(delta: float):
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	if animator.current_animation != "walk":
		return

	animator.speed_scale = abs(player.velocity.x) / 50

func start(new_direction: int = 1):
	super(new_direction)

	var player: Player = target
	var animator: AnimationPlayer = player.animator

	animator.play("walk")

func stop():
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	animator.speed_scale = 1
	animator.play("idle")
