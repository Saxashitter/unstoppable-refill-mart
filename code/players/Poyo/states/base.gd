extends State

@export var walk_speed: float = 150
@export var acceleration: float = 1000
@export var deceleration: float = 600
@export var run_speed: float = 230
@export var jump_height: float = 50

var _last_move_direction: int = 0

var running: bool = false

func enter():
	var input: PlayerInput = target.input
	var move: PlayerInputAnalogAction = input.get_input("Move")

	_last_move_direction = move.direction

func physics_process(delta: float):
	_handle_horizontal_movement(delta)
	target.gravity(delta)

	target.move_and_slide()

func _handle_horizontal_movement(delta: float):
	var input: PlayerInput = target.input

	var move: PlayerInputAnalogAction = input.get_input("Move")
	var jump: PlayerInputAction = input.get_input("Jump")
	var sprint: PlayerInputAction = input.get_input("Sprint")

	var velocity_direction: int = int(signf(target.velocity.x))

	if move.is_pressed() or (move.direction != 0 and move.direction == -_last_move_direction):
		running = sprint.is_down()

		# if were running, instantly thrust towards where we are going
		if running:
			if not running:
				run(move.direction, abs(target.velocity.x) <= walk_speed)
		else:
			walk(move.direction)

	if move.is_down() and sprint.is_pressed() and not running:
		run(move.direction)

	if move.is_down() and not sprint.is_down() and running:
		running = false
		walk(move.direction)

	_last_move_direction = move.direction

	var step: float = acceleration
	var speed: float = walk_speed * move.strength

	if not move.is_down():
		step = deceleration
	elif velocity_direction != 0 and move.direction == -velocity_direction:
		step *= 1.5

	if sprint.is_down() and move.direction != 0:
		speed = run_speed * move.direction

		if move.direction != target.direction:
			target.direction = move.direction

	target.velocity.x = move_toward(target.velocity.x, speed, step * delta)
	var new_velocity_direction: int = int(signf(target.velocity.x))

	if not move.is_down() and velocity_direction != 0 and target.velocity.x == 0:
		print("stand still")
		running = false

func run(direction: int, dash: bool = false):
	running = true
	target.direction = direction

	if dash:
		target.velocity.x = run_speed * direction

	print("run")
func walk(direction: int):
	target.direction = direction
	print("walk")
