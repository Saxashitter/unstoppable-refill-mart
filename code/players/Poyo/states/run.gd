extends State

@export var speed: float = 260
@export var skate_start_speed: float = 320
@export var skate_speed: float = 380
@export var skid_acceleration: float = 800
@export var run_acceleration: float = 300
@export var skate_acceleration: float = 50

@export var dash_sound: AudioStreamPlayer2D
@export var sound: AudioStreamPlayer2D
@export var pitch_range = Vector2.ONE

@export var leniency_manager: LeniencyManager

var _skating: bool = false
var _dash_on_start: bool = false
var _last_move_direction: int = 0

func enter():
	_skating = false

	var cur_direction: int = int(signf(target.velocity.x))

	if cur_direction == 0:
		cur_direction = target.direction

	_last_move_direction = cur_direction

	if _dash_on_start:
		target.velocity.x = speed * cur_direction
		dash_sound.play()

	
	target.direction = cur_direction

	if can_skate():
		skate(true)
	else:
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

func can_skate() -> bool:
	var input: PlayerInput = target.input
	var move: PlayerInputAnalogAction = input.get_input("Move")

	var velocity_direction: int = int(signf(target.velocity.x))
	var player_speed: float = abs(target.velocity.x)

	# fail-proof
	if velocity_direction == 0:
		velocity_direction = target.direction

	return move.direction == velocity_direction and player_speed >= speed

func skate(do_run_anim: bool = false):
	var input: PlayerInput = target.input
	var move: PlayerInputAnalogAction = input.get_input("Move")

	var velocity_direction: int = int(signf(target.velocity.x))
	var player_speed: float = abs(target.velocity.x)

	var move_direction: int = move.direction
	if move_direction == 0:
		move_direction = velocity_direction

	var max_speed: bool = move_direction == velocity_direction and player_speed == skate_speed
	var skate_anim: bool = move_direction == velocity_direction and player_speed >= skate_start_speed

	if max_speed:
		target.animator.play("Skate")
	elif skate_anim:
		target.animator.play("Skating")
	elif do_run_anim:
		target.animator.play("Running")

	_skating = true

func _handle_horizontal_movement(delta: float) -> bool:
	var input: PlayerInput = target.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var sprint: PlayerInputAction = input.get_input("Sprint")

	var velocity_direction: int = int(signf(target.velocity.x))
	var player_speed: float = abs(target.velocity.x)

	# fail-proof
	if velocity_direction == 0:
		velocity_direction = target.direction

	var move_direction: int = move.direction
	if move_direction == 0:
		move_direction = velocity_direction

	var target_speed: float = speed * move_direction
	var target_acceleration: float = run_acceleration
	var skidding: bool = move_direction == -velocity_direction

	if can_skate():
		target_speed = skate_speed * move_direction
		target_acceleration = skate_acceleration

		if not _skating:
			skate()
			print("yay")
	elif _skating:
		if move.direction == 0 and target.animator.current_animation.name != "Running":
			target.animator.play("Running")

		_skating = false

	if move_direction != _last_move_direction:
		if skidding:
			target.animator.play("Skid")
		if move_direction == velocity_direction and not can_skate():
			target.animator.play("Running")

		_last_move_direction = move_direction

	if skidding:
		target_acceleration = skid_acceleration

	target.velocity.x = move_toward(target.velocity.x, target_speed, target_acceleration * delta)
	var new_velocity_direction: int = int(signf(target.velocity.x))
	var new_player_speed: float = abs(target.velocity.x)
	if _skating and new_velocity_direction == move_direction and new_player_speed == skate_speed:
		target.animator.play("Skate")
	elif _skating and new_velocity_direction == move_direction and player_speed < skate_start_speed and new_player_speed >= skate_start_speed:
		target.animator.play("Skating")
		print("skoot")
	#target.camera.camera_offset.x = lerp(target.camera.camera_offset.x, 100.0 * move_direction, 0.03)

	if new_velocity_direction == 0:
		new_velocity_direction = -velocity_direction

	if velocity_direction == -new_velocity_direction:
		target.direction *= -1
		target.animator.play("Running")

	var air_state: State = states["Air"]
	var base_state: State = states["Walk"]
	var jump_height: float = air_state.jump_height
	if air_state.safe_set(func():
		air_state.jumped = true
		air_state.speed = speed
		if _skating:
			air_state.speed = player_speed
		if skidding:
			air_state.jump_height *= 1.08
		target.move_and_slide()
	):
		if skidding:
			target.direction = move_direction
			target.animator.play("Spinjump")
			target.velocity.x = speed * move_direction
		air_state.jump_height = jump_height
		return true

	if sprint.is_released():
		machine.set_state(base_state)
		target.animator.play("Walking")
		target.direction = move_direction
		return true

	leniency_manager.update(delta)
	return false

func _update_animation() -> void:
	var speed_frac: float = abs(target.velocity.x) / speed
	var run_anim: SpriteAnimation = target.animator.get_animation("Running")

	run_anim.speed = 3 * speed_frac

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
