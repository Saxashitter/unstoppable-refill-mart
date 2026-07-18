extends Control

var game: PackedScene = preload("res://code/gamestates/Game/scene.tscn")

func start_singleplayer() -> void:
	var gamestate: Node2D = game.instantiate()
	get_tree().change_scene_to_node(gamestate)
