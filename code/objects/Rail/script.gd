extends Path2D
class_name Rail

@onready var area: Area2D = $Area2D
@onready var follow: PathFollow2D = $PathFollow2D

# players are responsible for checking rail collisions. this is merely for setting variables

func get_intercept_offset(player: Player) -> float:
	var raw_offset: float = curve.get_closest_offset(to_local(player.global_position))
	return raw_offset / curve.get_baked_length()

func get_intercept_position(player: Player) -> Vector2:
	var offset: float = get_intercept_offset(player)
	return to_global(curve.sample_baked(offset))

func get_intercept_direction(player: Player, ratio: float) -> Vector2:
	var offset: float = ratio * curve.get_baked_length()
	var tangent: Vector2 = (to_global(curve.sample_baked(offset + 1.0)) - to_global(curve.sample_baked(offset))).normalized()
	
	if player.velocity.dot(tangent) < 0.0:
		tangent = -tangent
	
	return tangent

func get_intercept_position_by_ratio(player: Player, ratio: float) -> Vector2:
	var offset: float = ratio * curve.get_baked_length()
	return to_global(curve.sample_baked(offset))
