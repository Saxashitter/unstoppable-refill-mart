extends PoyoMovementState
class_name PoyoDashState

## poyos run state

@export var skid_state: PoyoSkidState
@export var jump_state: PoyoDashJumpState
@export var grind_state: PoyoGrindState
@export var leniency_manager: LeniencyManager
@export var grind_area: Area2D

@export var speedup_speed: float = 0
@export var skate_speed: float = 0
@export var max_speed: float = 0
@export var should_set_dash_state: bool = false
@export var should_speedup: bool = false
@export var buffer_deceleration: float = 10
@export var buffer_add: float = 20
@export var dash_dance_leniency: float = 0.1

var rail_grinding: bool = false
var dash_dance_time: float = 0
@onready var _speed: float = speed # to reset...

var dash_on_start: bool = true

enum DashType {
	RUN, # the player is still technically running
	SPEEDUP, # the player is moving their skateboard forward
	SKATE # the max skateboard speed
}
var type: DashType = DashType.RUN

func enter():
	super()

	speed = _speed

	var player: Player = target
	player.camera.state_machine.set_state_by_name("Run")

	if dash_on_start and abs(player.velocity.x) < speed:
		player.velocity.x = speed * player.direction
		dash_dance_time = dash_dance_leniency
	else:
		dash_dance_time = 0

	set_dash_type(get_dash_type())
	dash_on_start = true

func physics_process(delta: float) -> void:
	if handle_dash(delta): return
	vertical_movement(delta)

	if grind_state.should_grind():
			machine.set_state(grind_state)
			return
	#var floorcast: ShapeCast2D = player.floorcast
#
	#if rail_grinding and player.is_on_floor() and floorcast.is_colliding():
		#print("GRIND")

	leniency_manager.update(delta)

	target.move_and_slide()
	jump_state.safe_jump()

func _process(delta: float):
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	if animator.current_animation != "run":
		return

	animator.speed_scale = abs(player.velocity.x) / 80

func handle_dash(delta: float) -> bool:
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	var input: PlayerInput = player.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var sprint: PlayerInputAction = input.get_input("Sprint")

	var direction: int = player.direction

	var old_direction: int = int(signf(player.velocity.x))
	var old_speed: float = player.velocity.x * old_direction

	if should_speedup:
		# handle player input stuff
		speed = max(_speed, speed - buffer_deceleration * delta)

		if move.is_pressed() and move.direction == direction and old_speed >= _speed:
			if type == DashType.SPEEDUP:
				animator.play("RESET")
				animator.play("skating")
			speed = min(speed + buffer_add, max_speed)
			player.velocity.x = speed * direction

	player.velocity.x = move_toward(player.velocity.x, speed * direction, acceleration * delta)

	var new_speed: float = player.velocity.x * old_direction

	dash_dance_time = max(0, dash_dance_time - delta)

	if move.direction == -direction and dash_dance_time > 0:
		player.direction *= -1
		machine.set_state(self)
		return true

	if move.direction == -direction or not sprint.is_down():
		machine.set_state(skid_state)
		return true

	# ...this is probably a bit messy
	if should_set_dash_state:
		var target_type: DashType = get_dash_type()

		if type != target_type:
			set_dash_type(target_type)

	return false

func enable_rail_grinding(value: bool = not rail_grinding):
	var player: Player = target
	rail_grinding = value
	player.set_collision_mask_value(5, value)

func set_dash_type(new_type: DashType = type):
	var player: Player = target
	var animator: AnimationPlayer = player.animator

	match new_type:
		DashType.RUN:
			enable_rail_grinding(false)
			animator.play("run")
		DashType.SPEEDUP:
			enable_rail_grinding(true)
			animator.speed_scale = 1
			animator.play("skating")
		DashType.SKATE:
			enable_rail_grinding(true)
			animator.speed_scale = 1
			animator.play("skate")

	type = new_type

func get_dash_type():
	var player: Player = target
	var speed: float = abs(player.velocity.x)

	if speed >= skate_speed:
		return DashType.SKATE
	if speed > speedup_speed:
		return DashType.SPEEDUP

	return DashType.RUN

#extends State
#
#@export var speed: float = 260
#@export var skate_start_speed: float = 320
#@export var skate_speed: float = 380
#@export var skid_acceleration: float = 800
#@export var run_acceleration: float = 300
#@export var skate_acceleration: float = 50
#
#@export var dash_sound: AudioStreamPlayer2D
#@export var sound: AudioStreamPlayer2D
#@export var pitch_range = Vector2.ONE
#
#@export var leniency_manager: LeniencyManager
#
#var _dash_on_start: bool = false
#var _last_move_direction: int = 0
#
#func enter():
	#var cur_direction: int = int(signf(target.velocity.x))
#
	#if cur_direction == 0:
		#cur_direction = target.direction
#
	#_last_move_direction = cur_direction
#
	#if _dash_on_start:
		#target.velocity.x = speed * cur_direction
		#dash_sound.play()
#
	#
	#target.direction = cur_direction
#
	#target.animator.play("Running")
#
	##target.camera.keep_in_limits = false
	##target.camera._camera_position = target.camera.get_target_position_of_camera()
	#if target.camera.state_machine.current_state.name != "Run":
		#target.camera.state_machine.set_state_by_name("Run")
#
#func physics_process(delta: float) -> void:
	#if _handle_horizontal_movement(delta): return
#
	#target.gravity(delta)
	#target.move_and_slide()
#
#func process(delta: float) -> void:
	#_update_animation()
#
#func exit():
	#rails(false)
#
#func can_skate() -> bool:
	#var input: PlayerInput = target.input
	#var move: PlayerInputAnalogAction = input.get_input("Move")
#
	#var velocity_direction: int = int(signf(target.velocity.x))
	#var player_speed: float = abs(target.velocity.x)
#
	## fail-proof
	#if velocity_direction == 0:
		#velocity_direction = target.direction
#
	#return move.direction == velocity_direction and player_speed >= speed
#
#func rails(boolean: bool = true):
	#var player: Player = target
	#player.set_collision_mask_value(5, boolean)
#
#func _handle_horizontal_movement(delta: float) -> bool:
	#var input: PlayerInput = target.input
	#var move: PlayerInputAnalogAction = input.get_input("Move")
	#var sprint: PlayerInputAction = input.get_input("Sprint")
#
	#var velocity_direction: int = int(signf(target.velocity.x))
	#var player_speed: float = abs(target.velocity.x)
#
	## fail-proof
	#if velocity_direction == 0:
		#velocity_direction = target.direction
#
	#var move_direction: int = move.direction
	#if move_direction == 0:
		#move_direction = velocity_direction
#
	#var target_speed: float = speed * move_direction
	#var target_acceleration: float = run_acceleration
	#var skidding: bool = move_direction == -velocity_direction
#
	#if move_direction != _last_move_direction:
		#if skidding:
			#target.animator.play("Skid")
		#if move_direction == velocity_direction and not can_skate():
			#target.animator.play("Running")
#
		#_last_move_direction = move_direction
#
	#if skidding:
		#target_acceleration = skid_acceleration
#
	#target.velocity.x = move_toward(target.velocity.x, target_speed, target_acceleration * delta)
	#var new_velocity_direction: int = int(signf(target.velocity.x))
	#var new_player_speed: float = abs(target.velocity.x)
	##target.camera.camera_offset.x = lerp(target.camera.camera_offset.x, 100.0 * move_direction, 0.03)
#
	#if new_velocity_direction == 0:
		#new_velocity_direction = -velocity_direction
#
	#if velocity_direction == -new_velocity_direction:
		#target.direction *= -1
		#target.animator.play("Running")
#
	#var air_state: State = states["Air"]
	#var base_state: State = states["Walk"]
	#var jump_height: float = air_state.jump_height
	#if air_state.safe_set(func():
		#air_state.jumped = true
		#air_state.speed = speed
		#if skidding:
			#air_state.jump_height *= 1.25
		#target.move_and_slide()
	#):
		#if skidding:
			#target.direction = move_direction
			#target.animator.play("Spinjump")
			#target.velocity.x = speed * move_direction
		#air_state.jump_height = jump_height
		#return true
#
	#if sprint.is_released():
		#machine.set_state(base_state)
		#target.animator.play("Walking")
		#target.direction = move_direction
		#return true
#
	#leniency_manager.update(delta)
	#return false
#
#func _update_animation() -> void:
	#var speed_frac: float = abs(target.velocity.x) / speed
	#var run_anim: SpriteAnimation = target.animator.get_animation("Running")
#
	#run_anim.speed = 3 * speed_frac
#
#func could():
	#var input: PlayerInput = target.input
	#var sprint: PlayerInputAction = input.get_input("Sprint")
#
	#if not target.is_on_floor(): return false
	#if not sprint.is_down(): return false
#
	#return true
#
#func _on_running_new_frame(frame: int) -> void:
	#if frame == 0 or frame == 6:
		#sound.pitch_scale = pitch_range.x + (randf() * (pitch_range.y - pitch_range.x))
		#sound.play()
