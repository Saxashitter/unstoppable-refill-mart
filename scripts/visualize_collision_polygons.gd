extends Map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collisions = get_node("Collisions")

	for polygon in collisions.get_children():
		if !polygon.is_class("CollisionPolygon2D"): continue

		var visual: Polygon2D = Polygon2D.new()
		visual.position = polygon.position
		visual.polygon = polygon.polygon
		# visual.polygons = polygon.polygons
		$Visuals.add_child(visual)
