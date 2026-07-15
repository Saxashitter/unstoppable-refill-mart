extends State

@export var speed: float = 150
@export var acceleration: float = 600
@export var deceleration: float = 200
@export var jump_height: float = 380

@export var sound: AudioStreamPlayer2D
@export var pitch_range = Vector2.ONE

var jumped: bool = false # if true, the player goes into their jump animation upon entering the state. otherwise, the fall animation
var _jumped: bool = false # this is to keep our knowledge lmfao
var _halved_jump: bool = false # if jumped is true, and the player releases jump, their jump height will be halved.

func enter():
	if jumped:
		_jumped = true
		_halved_jump = false

		target.velocity.y = -jump_height
		target.animator.play("Jump")

		sound.pitch_scale = pitch_range.x + (randf() * (pitch_range.y - pitch_range.x))
		sound.play()
	else:
		_jumped = false
		_halved_jump = false
		target.animator.play("Fall")
		target.animator.current_frame = target.animator.current_animation.loop_frame

	jumped = false

func physics_process(delta: float) -> void:
	var base_state: State = states["Walk"]
	_handle_horizontal_movement(delta)
	if _handle_jump(): return
	target.gravity(delta)
	target.move_and_slide()
	if _handle_grounded(): return
	base_state._update_jump_leniency(delta)

func _handle_horizontal_movement(delta: float) -> void:
	var input: PlayerInput = target.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var jump: PlayerInputAction = input.get_input("Jump")

	var velocity_direction: int = int(signf(target.velocity.x))
	var target_speed: float = speed * move.strength
	var step: float = acceleration
	var base_state: State = states["Walk"]

	if not move.is_down():
		step = deceleration

	target.velocity.x = move_toward(target.velocity.x, target_speed, step * delta)

func _handle_jump() -> bool:
	if not _jumped:
		return safe_set(func():
			jumped = true
		)

	# handle anim
	if target.animator.current_animation.name == "Jump" and target.velocity.y >= 0:
		target.animator.play("Fall")

	if _halved_jump: return false

	var input: PlayerInput = target.input
	var jump: PlayerInputAction = input.get_input("Jump")

	if jump.is_down(): return false
	_halved_jump = true
	if target.velocity.y > 0: return false

	target.velocity.y /= 2
	return false

func _handle_grounded() -> bool:
	if target.is_on_floor():
		var state = states["Walk"].get_target_grounded_state()

		if state == states["Walk"]:
			if target.velocity.x != 0:
				target.animator.play("Walking")
			else:
				target.animator.play("Idle")

		if state == states["Run"]:
			state.dash_on_start = false

		var direction: int = int(signf(target.velocity.x))
		if direction == 0:
			direction = target.direction

		target.direction = direction
		machine.set_state(state)
		return true

	return false

func could():
	var base_state: State = states["Walk"]
	var input: PlayerInput = target.input
	var jump: PlayerInputAction = input.get_input("Jump")

	if not jump.is_pressed(): return false
	if base_state._jump_leniency == 0: print("no"); return false

	return true
