extends State

@export var speed: float = 230
@export var skid_acceleration: float = 800

@export var sound: AudioStreamPlayer2D
@export var pitch_range = Vector2.ONE

var dash_on_start: bool = false
var _last_move_direction: int = 0

func enter():
	var cur_direction: int = int(signf(target.velocity.x))
	if cur_direction == 0:
		cur_direction = target.direction

	_last_move_direction = cur_direction

	if dash_on_start:
		target.velocity.x = speed * cur_direction

	target.direction = cur_direction
	target.animator.play("Running")
	#target.camera.keep_in_limits = false
	#target.camera._camera_position = target.camera.get_target_position_of_camera()
	if target.camera.state_machine.current_state.name != "Run":
		target.camera.state_machine.set_state_by_name("Run")

func physics_process(delta: float) -> void:
	if _handle_horizontal_movement(delta): return

	target.gravity(delta)
	target.move_and_slide()

func process(delta: float) -> void:
	_update_animation()

func _handle_horizontal_movement(delta: float) -> bool:
	var input: PlayerInput = target.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var sprint: PlayerInputAction = input.get_input("Sprint")

	var velocity_direction: int = int(signf(target.velocity.x))
	# fail-proof
	if velocity_direction == 0:
		velocity_direction = target.direction

	var move_direction: int = move.direction
	if move_direction == 0:
		move_direction = velocity_direction

	var target_speed: float = speed * move_direction

	if move_direction != _last_move_direction:
		if move_direction == -velocity_direction:
			target.animator.play("Skid")
		if move_direction == velocity_direction:
			target.animator.play("Running")

		_last_move_direction = move_direction

	target.velocity.x = move_toward(target.velocity.x, target_speed, skid_acceleration * delta)
	target.camera.camera_offset.x = lerp(target.camera.camera_offset.x, 100.0 * move_direction, 0.03)

	var new_velocity_direction: int = int(signf(target.velocity.x))
	if new_velocity_direction == 0:
		new_velocity_direction = -velocity_direction

	if velocity_direction == -new_velocity_direction:
		target.direction *= -1
		target.animator.play("Running")

	var air_state: State = states["Air"]
	var base_state: State = states["Walk"]
	if air_state.safe_set(func():
		air_state.jumped = true
		air_state.speed = speed
		target.move_and_slide()
	):
		return true

	if sprint.is_released():
		machine.set_state_by_name("Walk")
		target.animator.play("Walking")
		target.direction = move_direction
		return true

	base_state._update_jump_leniency(delta)
	return false

func _physics_process(delta: float):
	pass

func _update_animation() -> void:
	var speed_frac: float = abs(target.velocity.x) / speed
	var run_anim: SpriteAnimation = target.animator.get_animation("Running")

	run_anim.speed = 2.5 * speed_frac

func could():
	var input: PlayerInput = target.input
	var sprint: PlayerInputAction = input.get_input("Sprint")

	if not target.is_on_floor(): return false
	if not sprint.is_down(): return false

	return true

func _on_running_new_frame(frame: int) -> void:
	if frame == 0 or frame == 6:
		sound.pitch_scale = pitch_range.x + (randf() * (pitch_range.y - pitch_range.x))
		sound.play()
