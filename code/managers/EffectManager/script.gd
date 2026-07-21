extends Node
class_name EffectManager

@export var target: Node2D
@export var sprites: Array[Sprite2D] = []

func ghost_effect(color: Color = Color.RED, duration: float = 0.1):
	var duplicates: Node2D = Node2D.new()
	add_child(duplicates)

	duplicates.name = "Ghost"
	duplicates.top_level = true
	duplicates.global_position = target.global_position

	var transparency_tween: Tween = get_tree().create_tween()
	var position_tween: Tween = get_tree().create_tween()
	var scale_tween: Tween = get_tree().create_tween()
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	var material: ShaderMaterial = ShaderMaterial.new()

	material.shader = load("res://code/shaders/multiply.gdshader")

	color.a *= 0.2

	for sprite in sprites:
		var duplicate: Sprite2D = sprite.duplicate()

		duplicate.position = sprite.position
		duplicate.material = material
		duplicates.add_child(duplicate)

	duplicates.modulate = color
	transparency_tween.tween_property(duplicates, "modulate:a", 0, duration)
	position_tween.tween_property(duplicates, "position:y", duplicates.position.y - 25, duration)
	scale_tween.tween_property(duplicates, "scale", duplicates.scale * 2, duration)

	timer.timeout.connect(func():
		remove_child(duplicates)
	)
