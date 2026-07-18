extends State

@export var camera_stasis_time: float = 0.25
@export var turn_stasis_time: float = 0.5

@export var lookahead_distance: float = 80
@export var lookahead_distance_further: float = 100
@export var lookahead_distance_speed_further: float = 8
@export var lookahead_distance_speed_closer: float = 25
@export var lookahead_speed: float = 200
@export var lookahead_time: float = 1

var _lookahead_distance: float = lookahead_distance

var offset: float = 0

func enter():
	var player: Player = target.get_parent()
	offset = target.position.x - player.position.x
	_lookahead_distance = lookahead_distance

func process(delta: float):
	var player: Player = target.get_parent()
	var input: PlayerInput = player.input
	var move: PlayerInputAnalogAction = input.get_input("Move")

	var direction: int = player.direction
	var base: State = states["Base"]
	#var player_run: State = player.state_machine.states["Run"]

	# update x and move offset towards where we are going
	#if player_run._skating and offset == _lookahead_distance * direction:
		#_lookahead_distance = move_toward(
			#_lookahead_distance,
			#lookahead_distance_further,
			#lookahead_distance_speed_further * delta
		#)
	#else:
		#_lookahead_distance = move_toward(
			#_lookahead_distance,
			#lookahead_distance,
			#lookahead_distance_speed_closer * delta
		#)
	offset = move_toward(offset, _lookahead_distance * direction, lookahead_speed * delta)
	target.position.x = player.position.x + offset

	# update y with base cam function
	base._update_y_position(delta)
