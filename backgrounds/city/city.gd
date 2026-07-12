extends Node2D

@onready var background: Sprite2D = $Parallax2D/Layer0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cam: Camera2D = get_viewport().get_camera_2d()

	if not cam: return

	background.scale = Vector2.ONE / cam.zoom
