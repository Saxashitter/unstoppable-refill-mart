extends State
class_name PoyoGrindState

## poyo can GRIND ON RAILS???? OMAGADD?????
@export var grind_area: Area2D
@export var dash_state: PoyoDashState
@export var jump_state: PoyoDashJumpState

func enter():
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	animator.play("grind")
	player.velocity.y = 0

func physics_process(delta: float):
	var player: Player = target
	var input: PlayerInput = player.input
	var jump: PlayerInputAction = input.get_input("Jump")
	var animator: AnimationPlayer = player.animator

	player.move_and_slide()

	var areas: Array[Area2D] = grind_area.get_overlapping_areas()

	if areas.size() == 0 or not player.is_on_floor():
		if player.is_on_floor():
			machine.set_state(dash_state)
		else:
			machine.set_state(jump_state)

	if jump.is_pressed():
		machine.set_state(jump_state)

func should_grind():
	var player: Player = target

	if player.is_on_floor() and dash_state.rail_grinding:
		var areas: Array[Area2D] = grind_area.get_overlapping_areas()
		if areas.size() > 0:
			return true

	return false
