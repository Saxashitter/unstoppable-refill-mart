extends CharacterBody2D
class_name Entity

@export var maximum_health: int = 1

var health = 1

signal damaged
signal died

func hurt(damage: int = 1, source: Entity = null):
	health -= damage

	if health <= 0:
		health = 0
		die(source)
		return

	damaged.emit(damage, source)

func die(source: Entity = null):
	died.emit(source)
	queue_free()
