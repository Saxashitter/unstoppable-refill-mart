extends State

@export var speed: float = 150
@export var acceleration: float = 1000
@export var deceleration: float = 600
@export var jump_leniency: float = 2

@export var sound: AudioStreamPlayer2D
@export var pitch_range = Vector2.ONE

var _jump_leniency: float = jump_leniency

func enter():
	if target.camera == null: return
	if target.camera.state_machine == null: return
	target.camera.state_machine.set_state_by_name("Base")

func physics_process(delta: float) -> void:
	if _handle_horizontal_movement(delta): return
	_update_jump_leniency(delta)

	target.gravity(delta)
	target.move_and_slide()

func process(delta: float) -> void:
	_update_animation()

func get_target_grounded_state() -> State:
	var input: PlayerInput = target.input
	var sprint: PlayerInputAction = input.get_input("Sprint")

	if sprint.is_down():
		return states["Run"]

	return self

func _handle_horizontal_movement(delta: float) -> bool:
	var input: PlayerInput = target.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var jump: PlayerInputAction = input.get_input("Jump")
	var sprint: PlayerInputAction = input.get_input("Sprint")

	var velocity_direction: int = int(signf(target.velocity.x))
	var target_speed: float = speed * move.strength
	var step: float = acceleration

	var run_state: State = states["Run"]
	var air_state: State = states["Air"]

	if run_state.safe_set(func():
		run_state.dash_on_start = abs(target.velocity.x) <= speed / 2
	):
		return true

	if air_state.safe_set(func():
		air_state.jumped = true
		air_state.speed = speed
	):
		return true

	if !target.is_on_floor():
		air_state.jumped = false
		air_state.speed = speed
		print("like this")
		machine.set_state(air_state)
		return true

	if move.is_pressed() or (move.direction != 0 and move.direction != target.direction) or move.reversed:
		walk(move.direction)

	if not move.is_down():
		step = deceleration
	elif velocity_direction != 0 and move.direction == -velocity_direction:
		step *= 1.5

	target.velocity.x = move_toward(target.velocity.x, target_speed, step * delta)

	if velocity_direction != 0 and target.velocity.x == 0 and not move.is_down():
		target.animator.play("Idle")

	return false
func _update_animation() -> void:
	var speed_frac: float = abs(target.velocity.x) / speed
	var walk_anim: SpriteAnimation = target.animator.get_animation("Walking")

	walk_anim.speed = 1.6 * speed_frac
func _update_jump_leniency(delta: float) -> void:
	if target.is_on_floor():
		_jump_leniency = jump_leniency
		return

	_jump_leniency = max(0, _jump_leniency - delta)

func walk(direction: int) -> void:
	target.direction = direction
	target.animator.play("Walking")

func _on_walk_frame(frame: int) -> void:
	if frame == 0 or frame == 4:
		sound.pitch_scale = pitch_range.x + (randf() * (pitch_range.y - pitch_range.x))
		sound.play()
