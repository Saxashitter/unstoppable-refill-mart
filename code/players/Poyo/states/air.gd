extends PoyoMovementState
class_name PoyoAirState

@export var jump_state: PoyoJumpState
@export var jump_leniency: bool = false

func enter():
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	animator.speed_scale = 1
	animator.play("fall_loop")
	#player.animator.play("Fall")
	#player.animator.current_frame = player.animator.current_animation.loop_frame

## poyos air state
func physics_process(delta: float) -> void:
	super(delta)

	var player: Player = target
	player.effects.ghost_effect()

	if manage_state_swap(): return

	if jump_leniency and jump_state.safe_jump(): return

func manage_state_swap() -> bool:
	var player: Player = target

	if player.is_on_floor():
		machine.set_state(get_target_landing_state())
		return true

	return false

func safe_fall():
	var player: Player = target
	var machine: StateMachine = player.state_machine

	if not player.is_on_floor():
		machine.set_state(self)
		return

func get_target_landing_state() -> State:
	return machine.states["Base"]
