extends Entity
class_name Player

@export var input: PlayerInput
@export var sprite: Sprite2D
@export var collider: CollisionShape2D

func _set_direction(direction: int):
	sprite.flip_h = direction == -front_facing

@export var front_facing: int = -1
@export var direction: int = 1:
	set(value):
		if not sprite: return
		direction = value
		_set_direction(direction)

var colas: int = 0
signal cola_collected

func collect_cola(cola: Entity):
	cola.queue_free()
	colas += 1
	cola_collected.emit()

func _ready() -> void:
	_set_direction(direction)
