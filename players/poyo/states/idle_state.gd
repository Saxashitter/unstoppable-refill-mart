extends State
class_name IdleState

@export var walk_speed: float = 100
@export var run_speed: float = 195
@export var walk_acceleration: float = 1000
@export var jump_power: float = 370
@export var tap_buffer_time: float = 0.25

@onready var animator: AnimationPlayer = $"../../Animator"
@onready var movement: Movement = $"../../Movement"
@onready var camera: PlayerCamera = $"../../PlayerCamera"

# run variables
var tap_timer: float = 0
var last_direction: int = 0
var run_direction: int = 0
var running: bool = false

# jump variables
var jumped: bool = false

func physics_process(player: Player, delta: float) -> void:
	var direction: int = movement.input_direction()

	_update_tap_buffer(delta)
	_update_run_state(player, direction)
	_handle_horizontal_movement(player, direction, delta)

	movement.apply_gravity(player, delta)
	_handle_jump(player, direction)

	if _handle_wall_state(player): return

	_update_animation(player, direction)

	player.move_and_slide()
	last_direction = direction


## Counts down the double-tap detection window.
func _update_tap_buffer(delta: float) -> void:
	if tap_timer > 0:
		tap_timer -= delta
		if tap_timer < 0:
			tap_timer = 0

## Detects double-taps to start running, and detects when running should stop.
func _update_run_state(player: Player, direction: int) -> void:
	if direction != 0 and last_direction != direction:
		if tap_timer > 0:
			run(player, direction)
		tap_timer = tap_buffer_time # so we can dashdance LOL

	# if we released our movement key, dont run
	var released_on_ground = player.is_on_floor() and direction != run_direction
	var reversed_in_air = !player.is_on_floor() and direction == -run_direction
	if (released_on_ground or reversed_in_air) and running:
		camera.camera_offset.x = 0
		running = false

func _handle_horizontal_movement(player: Player, direction: int, delta: float) -> void:
	if !running:
		movement.apply_friction(player, delta)
		if direction != 0:
			player.velocity.x = move_toward(player.velocity.x, walk_speed * direction, walk_acceleration * delta)
	else:
		if player.is_on_floor():
			player.velocity.x = run_speed * direction
		else:
			movement.apply_friction(player, delta)
			player.velocity.x = move_toward(player.velocity.x, run_speed * direction, walk_acceleration * delta)

## Jump start, jump reset on landing, and variable jump height on early release.
func _handle_jump(player: Player, direction: int) -> void:
	if player.is_on_floor() and jumped:
		jumped = false

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		if direction != 0:
			player.set_facing(direction)
		jump(player)

	if jumped and !Input.is_action_pressed("jump"):
		jumped = false
		if player.velocity.y < 0:
			player.velocity.y = 0

func jump(player: Player):
	animator.speed_scale = 1
	animator.play("jump")
	player.velocity.y = -jump_power
	player.sounds.get_node("Jump").play_pitch_rng()
	jumped = true

func run(player: Player, direction: int):
	camera.camera_offset.x = 100 * direction
	running = true
	run_direction = direction

## Handles wall clinging...
func _handle_wall_state(player: Player) -> bool:
	if not player.is_on_wall(): return false
	if player.is_on_floor(): return false

	var wallState: WallState = states["WallState"]
	wallState.wall_normal = player.get_wall_normal()
	machine.set_state(wallState)
	return true

func _update_animation(player: Player, direction: int) -> void:
	# grounded
	if player.is_on_floor() and animator.current_animation != "jump" and animator.current_animation != "jump_loop" and animator.current_animation != "fall":
		var speed = abs(player.velocity.x)
		if direction != 0:
			player.set_facing(direction)

		if speed == 0:
			animator.speed_scale = 1
			if animator.current_animation != "idle": animator.play("idle")
		elif speed > 0 and not running:
			animator.speed_scale = (speed / walk_speed) * 2
			if animator.current_animation != "walk":
				animator.play("walk")
		elif speed > 0 and running:
			animator.speed_scale = (speed / walk_speed) * 1.25
			if animator.current_animation != "run":
				animator.play("run")

	# air
	if (player.velocity.y >= 0 or player.is_on_floor()) and animator.current_animation == "jump_loop":
		animator.speed_scale = 1
		animator.play("fall")
