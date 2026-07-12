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
	# map.music.play()
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
	
	add_child(player)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
