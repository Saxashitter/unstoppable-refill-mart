@tool
extends Camera2D
class_name PlayerCamera

## Extended class of Camera2D

@export var keep_in_limits: bool = false:
	set(value):
		keep_in_limits = value
		if not Engine.is_editor_hint(): return

		queue_redraw()
@export var camera_limits: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO):
	set(value):
		camera_limits = value
		if not Engine.is_editor_hint(): return

		queue_redraw()
@export var camera_position: Vector2 = Vector2.ZERO # relative to player
@export var camera_offset: Vector2 = Vector2.ZERO
@export var camera_lerp_speed: float = 0.08 * 2

@onready var state_machine: StateMachine = $StateMachine

var _camera_position: Vector2 = Vector2.ZERO

func get_target_position_of_camera() -> Vector2:
	var parent: Player = get_parent()

	return parent.position + camera_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	top_level = true

	_camera_position = get_target_position_of_camera()
	position = _camera_position + camera_offset

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if Engine.is_editor_hint(): return
#
	#_update_camera_position(delta)
	#position = lerp(position, _camera_position + camera_offset, camera_lerp_speed)
#func _update_camera_position(delta: float):
	#var parent: Player = get_parent()
	#var target_position: Vector2 = get_target_position_of_camera()
#
	#if not keep_in_limits:
		#_camera_position = target_position
		#return
#
	#var limits: Rect2 = camera_limits
	#limits.position += _camera_position
#
	#if target_position.x < limits.position.x:
		#_camera_position.x = target_position.x - camera_limits.position.x
	#elif target_position.x > limits.position.x + limits.size.x:
		#_camera_position.x = target_position.x - camera_limits.position.x - camera_limits.size.x
#
	#if target_position.y < limits.position.y:
		#_camera_position.y = target_position.y - camera_limits.position.y
	#elif target_position.y > limits.position.y + limits.size.y:
		#_camera_position.y = target_position.y - camera_limits.position.y - camera_limits.size.y
#
	#if parent.is_on_floor():
		#_camera_position.y = move_toward(position.y, target_position.y, 60 * delta)
func _draw() -> void:
	if not Engine.is_editor_hint(): return
	if not keep_in_limits: return

	var limits: Rect2 = camera_limits
	limits.position += position
	draw_rect(limits, Color.GREEN, false, 2)
