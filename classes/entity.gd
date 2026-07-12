extends CharacterBody2D
class_name Entity

@export var maximum_health: int = 1

var health = 1

func on_died(source: Entity = null): pass
func on_damaged(damage: int = 1, source: Entity = null): pass

func hurt(damage: int = 1, source: Entity = null):
	health -= damage

	if health <= 0:
		health = 0
		die(source)
		return

	on_damaged(damage)

func die(source: Entity = null):
	print("died....")
	on_died(source)
