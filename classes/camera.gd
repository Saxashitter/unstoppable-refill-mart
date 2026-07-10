extends Camera2D
class_name PlayerCamera

## --- Horizontal look-ahead ---
@export var horizontal_look_distance: float = 120.0
@export var horizontal_look_speed: float = 2.5
@export var horizontal_return_speed: float = 100.0 # units/sec, not a lerp weight

## --- Vertical follow (e.g. based on fall/jump velocity) ---
@export var vertical_look_max: float = 120.0
@export var vertical_look_divisor: float = 4.0 # velocity.y * 0.25 == velocity.y / 4.0
@export var vertical_look_speed: float = 1.25

## --- Camera bounds ---
@export var bounds_smooth_speed: float = 4.0
var _bounds_smoothing: bool = false

## --- Camera position lock ---
var forced_position: Vector2

## --- Shake ---
var _shake_strength: float = 0.0
var _shake_decay: float = 5.0
var _rng := RandomNumberGenerator.new()

## --- Zoom ---
@export var default_zoom: Vector2 = Vector2.ONE
var _target_zoom: Vector2 = Vector2.ONE
@export var zoom_speed: float = 5.0


func _ready() -> void:
	_rng.randomize()
	_target_zoom = default_zoom
	zoom = default_zoom


func _process(delta: float) -> void:
	_update_shake(delta)
	_update_zoom(delta)


## Call every physics frame while running/moving fast, direction is -1/0/1.
func push_horizontal(direction: int, delta: float) -> void:
	if direction == 0:
		reset_horizontal(delta)
		return
	offset.x = lerp(offset.x, horizontal_look_distance * direction, horizontal_look_speed * delta)


## Smoothly returns horizontal offset to 0 (e.g. when idle/walking, not running).
func reset_horizontal(delta: float) -> void:
	offset.x = move_toward(offset.x, 0, horizontal_return_speed * delta)

## Call every physics frame with the player's current vertical velocity.
func follow_velocity_y(velocity_y: float, delta: float) -> void:
	var target_y: float = clamp(velocity_y / vertical_look_divisor, 0, vertical_look_max)
	offset.y = lerp(offset.y, target_y, vertical_look_speed * delta)


## --- Shake ---
func shake(strength: float, decay: float = 5.0) -> void:
	_shake_strength = strength
	_shake_decay = decay


func _update_shake(delta: float) -> void:
	if _shake_strength <= 0:
		return
	offset += Vector2(
		_rng.randf_range(-1, 1) * _shake_strength,
		_rng.randf_range(-1, 1) * _shake_strength
	)
	_shake_strength = move_toward(_shake_strength, 0, _shake_decay * delta)


## --- Zoom ---
func set_zoom_target(z: Vector2) -> void:
	_target_zoom = z

func _update_zoom(delta: float) -> void:
	zoom = zoom.lerp(_target_zoom, zoom_speed * delta)



func set_bounds(rect: Rect2, smooth: bool = true) -> void:
	if smooth:
		_bounds_smoothing = true
		_tween_limits_to(rect)
	else:
		_bounds_smoothing = false
		limit_left = int(rect.position.x)
		limit_top = int(rect.position.y)
		limit_right = int(rect.position.x + rect.size.x)
		limit_bottom = int(rect.position.y + rect.size.y)


func _tween_limits_to(rect: Rect2) -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "limit_left", int(rect.position.x), 1.0 / bounds_smooth_speed)
	tween.tween_property(self, "limit_top", int(rect.position.y), 1.0 / bounds_smooth_speed)
	tween.tween_property(self, "limit_right", int(rect.position.x + rect.size.x), 1.0 / bounds_smooth_speed)
	tween.tween_property(self, "limit_bottom", int(rect.position.y + rect.size.y), 1.0 / bounds_smooth_speed)
