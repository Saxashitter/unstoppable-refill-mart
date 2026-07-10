extends Node2D

var game: PackedScene = preload("res://scenes/game.tscn")
var fade: PackedScene = preload("res://transitions/fade.tscn")
var transition: SceneTransition

func _state_change():
	var scene: Node2D = game.instantiate()
	var hud: CanvasLayer = scene.get_node("HUD") as CanvasLayer

	if hud != null:
		transition.play_leaving = false
		transition.kill_on_finished = true
		transition.play()
		remove_child(transition)
		hud.add_child(transition)
		transition = null

	get_tree().change_scene_to_node(scene)

func _on_button_pressed() -> void:
	transition = fade.instantiate()
	transition.play_leaving = true
	transition.kill_on_finished = false
	transition.finished.connect(_state_change)
	add_child(transition)
