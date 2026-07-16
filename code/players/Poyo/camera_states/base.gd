extends State

@export var camera_reset_speed: float = 200

var _resetting: bool = false

# returns true if in bounds
func is_in_bounds(checkX: bool = true, checkY: bool = true) -> bool:
	var target_position: Vector2 = target.get_target_position_of_camera()
	var limits: Rect2 = target.camera_limits
	limits.position += target.position

	var insideX: bool = target_position.x >= limits.position.x and target_position.x <= limits.position.x + limits.size.x
	var insideY: bool = target_position.y >= limits.position.y and target_position.y <= limits.position.y + limits.size.y

	if checkX and not insideX:
		return false
	if checkY and not insideY:
		return false

	return true

func enter():
	if not is_in_bounds():
		_resetting = true

func process(delta: float):
	_update_camera_position(delta)

func _update_camera_position(delta: float) -> void:
	var parent: Player = target.get_parent()
	var target_position: Vector2 = target.get_target_position_of_camera()

	if not target.keep_in_limits:
		target.position = target_position
		return

	if _resetting:
		target.position = target.position.move_toward(target_position, camera_reset_speed * delta)
		if is_in_bounds():
			_resetting = false
		else:
			return

	_update_x_position(delta)
	_update_y_position(delta)


func _update_y_position(delta: float):
	var parent: Player = target.get_parent()
	var target_position: Vector2 = target.get_target_position_of_camera()

	var limits: Rect2 = target.camera_limits
	limits.position += target.position

	if target_position.y < limits.position.y:
		target.position.y = target_position.y - target.camera_limits.position.y
	elif target_position.y > limits.position.y + limits.size.y:
		target.position.y = target_position.y - target.camera_limits.position.y - target.camera_limits.size.y

	if parent.is_on_floor():
		target.position.y = move_toward(target.position.y, target_position.y, 1000 * delta)

func _update_x_position(delta: float):
	var target_position: Vector2 = target.get_target_position_of_camera()

	var limits: Rect2 = target.camera_limits
	limits.position += target.position

	if target_position.x < limits.position.x:
		target.position.x = target_position.x - target.camera_limits.position.x
	elif target_position.x > limits.position.x + limits.size.x:
		target.position.x = target_position.x - target.camera_limits.position.x - target.camera_limits.size.x
