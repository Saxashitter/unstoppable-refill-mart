extends Node2D

# TODO: load from either singleton or pass into thing somehow
var map_name: String = "test_map"
var player_name: String = "poyo"

# helper func
func instantiate_from_string(string: String, add: bool = true):
	var scene = load(string) # runtime load, not cached at compile time
	var instance = scene.instantiate()

	if add:
		add_child(instance)

	return instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# load map
	var map: Map = instantiate_from_string("res://maps/"+map_name+".tscn")
	map.get_spawns()
	map.music.play()

	# iterate through enemies and colas and set stuff
	for child in map.get_node("Colas").get_children():
		if child is not Entity: continue
		child.modulate = map.modulation
	for child in map.get_node("Enemies").get_children():
		if child is not Entity: continue
		child.modulate = map.modulation

	# spawn player
	var player: Player = instantiate_from_string("res://players/"+player_name+"/"+player_name+".tscn", false)

	# search for spawn points in the map
	# ONLY FOR THE PLAYER FOR NOW!!!
	var player_spawn: Spawn = map.get_spawn_point_for_type(player)
	if player_spawn != null:
		print("Spawn point found!")
		player.position = player_spawn.position
	else:
		print("Aaaww..")

	player.modulate = map.modulation
	add_child(player)
	pass

var exiting: bool = false
func _input(event: InputEvent):
	if not event is InputEventKey: return
	if event.keycode != KEY_F1: return
	if exiting: return
	exiting = true

	var game_class: PackedScene = load("res://scenes/menu.tscn")
	var game := game_class.instantiate()

	get_tree().change_scene_to_node(game)
