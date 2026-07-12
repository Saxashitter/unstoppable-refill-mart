extends Entity
class_name Player

var sprites: Array[Sprite2D]
var colliders: Array[CollisionShape2D]
@export var sounds: Node2D


func _ready() -> void:
	for child in get_children():
		if child is Sprite2D: sprites.append(child)
		if child is CollisionShape2D: colliders.append(child); print("hi")

func set_facing(direction: int):
	var flip: bool = direction > 0

	for sprite in sprites:
		sprite.flip_h = flip
