extends Camera2D
class_name PlayerCamera

@export var starting_offset: Vector2 = Vector2(0, 0)
@export var camera_lerp_speed: float = 0.035
@export var limit: bool = false

var camera_offset: Vector2 = Vector2(0, 0)

# private
var _camera_position: Vector2 = Vector2(0, 0)
var _camera_zoom: Vector2 = Vector2(0, 0)
var _camera_boundary_position: Vector2 = Vector2(0, 0)

var boundaries: Array[PlayerCameraBoundary] = []
var last_boundary: PlayerCameraBoundary = null
func get_current_boundary() -> PlayerCameraBoundary:
	if boundaries.is_empty():
		return null
	return boundaries[-1]

func get_player_position() -> Vector2:
	var parent: Player = get_parent()
	if not parent: return position
	var target_position = parent.position + starting_offset + camera_offset

	if limit:
		target_position.x = clamp(target_position.x, limit_left, limit_right)
		target_position.y = clamp(target_position.y, limit_top, limit_bottom)
	return target_position

func _ready():
	position = get_player_position()
	_camera_zoom = zoom

func _process(delta: float):
	var target_position = get_player_position()
	var current_boundary: PlayerCameraBoundary = get_current_boundary()
	var in_boundary: bool = current_boundary != null

	if not in_boundary:
		var parent: Player = get_parent()
		_camera_position.x = target_position.x
		if parent and (parent.is_on_floor() or parent.velocity.y > 0):
			_camera_position.y = target_position.y
		position = lerp(position, _camera_position, camera_lerp_speed)
		zoom = lerp(zoom, _camera_zoom, camera_lerp_speed)
	else:
		last_boundary = current_boundary

		var rect: Rect2 = current_boundary.calc_rect
		var new_zoom: Vector2 = _camera_zoom if current_boundary.containment_type == current_boundary.CAMSCALE_NONE else current_boundary.get_zoom()
		_camera_boundary_position = target_position
		_camera_boundary_position.x = clamp(_camera_boundary_position.x, rect.position.x, rect.position.x + rect.size.x)
		_camera_boundary_position.y = clamp(_camera_boundary_position.y, rect.position.y, rect.position.y + rect.size.y)
		position = lerp(position, _camera_boundary_position, camera_lerp_speed)
		zoom = lerp(zoom, new_zoom, camera_lerp_speed)
