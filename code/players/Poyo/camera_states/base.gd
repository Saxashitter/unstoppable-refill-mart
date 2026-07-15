extends State


func _update_y_position(delta: float):
	var parent: Player = target.get_parent()
	var target_position: Vector2 = target.get_target_position_of_camera()

	var limits: Rect2 = target.camera_limits
	limits.position += target._camera_position

	if target_position.y < limits.position.y:
		target._camera_position.y = target_position.y - target.camera_limits.position.y
	elif target_position.y > limits.position.y + limits.size.y:
		target._camera_position.y = target_position.y - target.camera_limits.position.y - target.camera_limits.size.y

	if parent.is_on_floor():
		target._camera_position.y = move_toward(target.position.y, target_position.y, 1000 * delta)

func _update_x_position(delta: float):
	var parent: Player = target.get_parent()
	var target_position: Vector2 = target.get_target_position_of_camera()

	var limits: Rect2 = target.camera_limits
	limits.position += target._camera_position

	if target_position.x < limits.position.x:
		target._camera_position.x = target_position.x - target.camera_limits.position.x
	elif target_position.x > limits.position.x + limits.size.x:
		target._camera_position.x = target_position.x - target.camera_limits.position.x - target.camera_limits.size.x

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _update_camera_position(delta: float) -> void:
	var parent: Player = target.get_parent()
	var target_position: Vector2 = target.get_target_position_of_camera()

	if not target.keep_in_limits:
		target._camera_position = target_position
		return

	_update_x_position(delta)
	_update_y_position(delta)

func process(delta: float):
	_update_camera_position(delta)
	target.position = lerp(target.position, target._camera_position + target.camera_offset, target.camera_lerp_speed)
