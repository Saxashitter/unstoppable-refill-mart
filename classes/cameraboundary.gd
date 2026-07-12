extends Area2D
class_name PlayerCameraBoundary

## boundary thing

# constants
var CAMSCALE_NONE: int = 0 # if containment type is this, camera doesnt scale
var CAMSCALE_WIDTH: int = 1 # if containment is this, camera scales by width, good for covering an area
var CAMSCALE_HEIGHT: int = 2 # if containment is this, camera scales by height, good for vertically covering an area

@export var containment_type: int = CAMSCALE_NONE
@export var collider: CollisionShape2D
@onready var calc_rect: Rect2 = get_rect()

func _ready() -> void:
	body_entered.connect(_player_entered)
	body_exited.connect(_player_exited)

func get_zoom() -> Vector2:
	var shape: RectangleShape2D = collider.shape
	var size: Vector2 = shape.get_rect().size
	var resolution: Vector2 = get_viewport_rect().size

	if containment_type == CAMSCALE_WIDTH:
		var z: float = resolution.x / max(size.x, 1.0)
		return Vector2(z, z)
	elif containment_type == CAMSCALE_HEIGHT:
		var z: float = resolution.y / max(size.y, 1.0)
		return Vector2(z, z)

	return Vector2(1, 1)

func get_rect() -> Rect2:
	var shape: RectangleShape2D = collider.shape
	var rect: Rect2 = shape.get_rect()
	rect.position += collider.position

	var scale: Vector2 = get_zoom()
	var screen_size: Vector2 = get_viewport_rect().size / scale
	rect.position += screen_size / 2
	rect.size -= screen_size
	rect.size.x = max(0, rect.size.x)
	rect.size.y = max(0, rect.size.y)
	return rect

func _player_entered(player: Player):
	var camera: PlayerCamera = player.get_node("PlayerCamera")
	if !camera: return
	if camera.boundaries.has(self): return
	print(containment_type)

	camera.boundaries.append(self)
	camera._camera_position = camera.position

func _player_exited(player: Player):
	var camera: PlayerCamera = player.get_node("PlayerCamera")
	if !camera: return
	if !camera.boundaries.has(self): return

	if camera.boundaries[camera.boundaries.size() - 1] == self:
		camera._camera_boundary_position = camera.position
	camera.boundaries.erase(self)
