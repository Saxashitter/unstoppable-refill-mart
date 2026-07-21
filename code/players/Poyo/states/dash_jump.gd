extends PoyoJumpState
class_name PoyoDashJumpState

## modified behavior for dash jump

@export var dash_state: PoyoDashState
@export var skid_state: PoyoSkidState
@export var grind_state: PoyoGrindState

@export var max_slowdown: float = 200
@export var slowdown_acceleration: float = 400

@onready var _speed: float = 0

func enter():
	_speed = abs(target.velocity.x)
	speed = _speed

	dash_state.dash_on_start = false
	play_fall_animation = dash_state.type == dash_state.DashType.RUN

	super()

	if not play_fall_animation:
		target.animator.play("kickflip")

func physics_process(delta: float) -> void:
	var player: Player = target
	var input: PlayerInput = player.input
	var jump: PlayerInputAction = input.get_input("Jump")

	if grind_state.should_grind():
		machine.set_state(grind_state)
		return

	if not jump.is_down() and not jump_halved:
		half_jump()

	if player.velocity.y >= 0 and not jump_descending:
		jump_descent()

	if not play_fall_animation: # WERE KICKFLIPPING. HYPE MOMENTS AND AURA
		player.effects.ghost_effect()

	super(delta)

func get_target_landing_state() -> State:
	var player: Player = target
	var input: PlayerInput = player.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var direction: int = move.direction
	var velocity_direction: int = int(signf(player.velocity.x))

	if direction == -velocity_direction:
		return skid_state

	dash_state.dash_on_start = false
	return dash_state


func horizontal_movement(delta: float) -> void:
	var player: Player = target
	var input: PlayerInput = player.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var direction: int = player.direction

	#var old_direction: int = int(signf(player.velocity.x))
	#var old_speed: float = player.velocity.x * old_direction

	if move.direction == -1:
		player.velocity.x = move_toward(player.velocity.x, speed * -1, slowdown_acceleration * delta)
	elif move.direction == 1:
		player.velocity.x = move_toward(player.velocity.x, speed, slowdown_acceleration * delta)

	#player.velocity.x = move_toward(player.velocity.x, speed * direction, dash_state.acceleration * delta)

	#var new_speed: float = player.velocity.x * old_direction

	#if move.direction == -direction or not sprint.is_down():
		#machine.set_state(skid_state)
		#return true
