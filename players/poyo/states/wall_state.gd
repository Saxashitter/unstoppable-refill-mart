extends State
class_name WallState

@onready var animator: AnimationPlayer = $"../../Animator"
@onready var movement: Movement = $"../../Movement"
@onready var camera: PlayerCamera = $"../../PlayerCamera"

@export var wall_cling_decrease_mult: float = 0.95

var wall_direction: int = 0
var wall_normal: Vector2 = Vector2(0, 0)

func enter(player: Player) -> void:
	player.velocity.x = 0
	animator.play("fall_loop")
	animator.speed_scale = 0
	wall_direction = sign(wall_normal.x)
	player.set_facing(wall_direction)

func physics_process(player: Player, delta: float) -> void:
	if _handle_cling(player): return
	_handle_jump(player)

func _handle_cling(player: Player) -> bool:
	player.velocity.y *= wall_cling_decrease_mult
	player.move_and_slide()

	if not player.is_on_wall() or player.is_on_floor():
		var idleState: IdleState = states["IdleState"]

		camera.camera_offset.x = 0
		idleState.tap_timer = 0
		idleState.last_direction = 0
		idleState.run_direction = 0
		idleState.running = false

		machine.set_state(idleState)
		return true

	return false
func _handle_jump(player: Player) -> bool:
	if !Input.is_action_just_pressed("jump"): return false

	var idleState: IdleState = states["IdleState"]

	player.velocity = wall_normal * idleState.run_speed
	camera.camera_offset.x = 0
	idleState.tap_timer = 0
	idleState.last_direction = 0
	idleState.run_direction = 0
	idleState.running = false

	if movement.input_direction() == wall_direction:
		idleState.run(player, wall_direction)

	idleState.jump(player)
	machine.set_state(idleState)
	player.move_and_slide()
	return true
