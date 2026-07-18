extends Control

var game: PackedScene = preload("res://code/gamestates/Game/scene.tscn")
var multiplayer_menu: PackedScene = preload("res://code/gamestates/MultiplayerMenu/scene.tscn")

func start_singleplayer() -> void:
	var gamestate: Node2D = game.instantiate()
	get_tree().change_scene_to_node(gamestate)


func start_multiplayer() -> void:
	var gamestate: Control = multiplayer_menu.instantiate()
	get_tree().change_scene_to_node(gamestate)
