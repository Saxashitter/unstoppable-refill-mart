extends Entity
class_name Cola

@onready var animator: AnimationPlayer = $AnimationPlayer
var collected: bool = false

func _collect(body: Node2D) -> void:
	if collected: return

	collected = true
	animator.play("collect")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "collect":
		queue_free()
