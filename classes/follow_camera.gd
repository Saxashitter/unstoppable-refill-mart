@tool
extends Camera2D
class_name FollowCamera

var original_position: Vector2
var use_boundary: bool = true

@export var boundary: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO):
	set(value):
		boundary = value
		queue_redraw()

func _ready():
	original_position = position
	global_position = get_parent().global_position + original_position
	top_level = true

func _draw() -> void:
	if !Engine.is_editor_hint(): return
	var _boundary = boundary
	_boundary.position += offset
	draw_rect(_boundary, Color(1, 0, 0, 0.5), false)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	var character := get_parent() as Player
	if character == null:
		return

	if character.colliders.size() == 0:
		return

	var collision := character.colliders[0]
	if collision == null:
		return

	var shape := collision.shape as CapsuleShape2D
	if shape == null:
		return

	var target := collision.global_position
	var cam := global_position

	if use_boundary:
		var horizontal_extent = shape.radius
		var vertical_extent = shape.height / 2

		var body_left = target.x - horizontal_extent
		var body_right = target.x + horizontal_extent
		var body_top = target.y - vertical_extent
		var body_bottom = target.y + vertical_extent

		var left = cam.x + boundary.position.x
		var right = left + boundary.size.x

		var top = cam.y + boundary.position.y
		var bottom = top + boundary.size.y

		if body_left < left:
			cam.x += body_left - left
		elif body_right > right:
			cam.x += body_right - right

		if body_top < top:
			cam.y += body_top - top
		elif body_bottom > bottom:
			cam.y += body_bottom - bottom

		if character.is_on_floor():
			cam.y = move_toward(cam.y, target.y + original_position.y, 70 * delta)

		global_position = cam
