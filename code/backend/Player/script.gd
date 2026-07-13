extends Entity
class_name Player

@export var input: PlayerInput
@export var sprite: Sprite2D
@export var collider: CollisionShape2D

@export var front_facing: int = -1
@export var direction: int = 1:
	set(value):
		if not sprite: return
		sprite.flip_h = value == -front_facing
		direction = value
