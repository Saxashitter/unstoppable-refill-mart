extends State

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta: float) -> void:
	_update_camera_position(delta)
	target.position = lerp(target.position, target._camera_position + target.camera_offset, target.camera_lerp_speed)
	pass

func exit():
	target.camera_offset = Vector2.ZERO

func _update_camera_position(delta: float):
	var parent: Player = target.get_parent()
	var input: PlayerInput = parent.input
	var move: PlayerInputAnalogAction = input.get_input("Move")
	var direction: int = move.direction
	if direction == 0:
		direction = parent.direction
	var base_state: State = states["Base"]

	var offset: Vector2 = Vector2(100.0 * direction, 0)
	target._camera_position.x = target.get_target_position_of_camera().x
	if parent.is_on_floor():
		target.camera_offset.x = lerp(target.camera_offset.x, offset.x, delta * 0.5)

	base_state._update_y_position(delta)
