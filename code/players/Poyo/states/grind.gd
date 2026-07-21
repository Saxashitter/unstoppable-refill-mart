extends State
class_name PoyoGrindState
## poyo can GRIND ON RAILS???? OMAGADD?????

@export var grind_area: Area2D
@export var dash_state: PoyoDashState
@export var jump_state: PoyoDashJumpState
@export var rail: Rail

var rail_offset: float = 0.0  # 0-1 ratio along the rail
var rail_speed: float = 0.0

func enter():
	var player: Player = target
	var animator: AnimationPlayer = player.animator
	animator.play("grind")

func physics_process(delta: float):
	var player: Player = target
	var input: PlayerInput = player.input
	var jump: PlayerInputAction = input.get_input("Jump")

	var direction: Vector2 = rail.get_intercept_direction(player, rail_offset)
	rail_offset += (rail_speed * delta) / rail.curve.get_baked_length()
	rail_offset = clamp(rail_offset, 0.0, 1.0)

	player.velocity = direction * rail_speed
	print(player.velocity)
	player.global_position = rail.get_intercept_position_by_ratio(player, rail_offset)

	var areas: Array[Area2D] = grind_area.get_overlapping_areas()
	if areas.size() == 0:
		if player.is_on_floor():
			machine.set_state(dash_state)
		else:
			machine.set_state(jump_state)
	if jump.is_pressed():
		machine.set_state(jump_state)

func should_grind():
	var player: Player = target
	if dash_state.rail_grinding:
		var areas: Array[Area2D] = grind_area.get_overlapping_areas()
		if areas.size() > 0:
			var area: Area2D = areas[0]
			var parent: Node = area.get_parent()
			if parent is not Rail: return false
			rail = parent
			rail_offset = rail.get_intercept_offset(player)
			rail_speed = player.velocity.length()
			player.global_position = rail.get_intercept_position_by_ratio(player, rail_offset)
			player.velocity = rail.get_intercept_direction(player, rail_offset) * rail_speed
			print(player.velocity)
			return true
	return false
