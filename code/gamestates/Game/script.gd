extends Node2D

@export var player_name: String = "Poyo"
@export var map_name: String = "TestMap"

@onready var players: Node2D = $Players
@onready var ui: GameUI = $GameUI

var map: Map
var player_spawn: PlayerSpawn

func on_peer_connected(pid: int):
	add_player(pid, "Poyo", player_spawn)

func on_peer_disconnected(pid: int):
	if players.has_node(str(pid)):
		players.remove_child(players.get_node(str(pid)))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map_scene: PackedScene = load("res://code/maps/" + map_name + "/scene.tscn")

	map = map_scene.instantiate()
	add_child(map)

	for child in map.spawns.get_children():
		if child is PlayerSpawn:
			player_spawn = child
			break

	if not (multiplayer.has_multiplayer_peer() and not multiplayer.is_server()):
		var player = add_player(1, "Poyo", player_spawn)
		initalize_client_player(player)

	if multiplayer.has_multiplayer_peer():
		if multiplayer.is_server():
			multiplayer.peer_connected.connect(on_peer_connected)
			multiplayer.peer_disconnected.connect(on_peer_disconnected)
		else:
			multiplayer.server_disconnected.connect(func():
				get_tree().change_scene_to_file("res://code/gamestates/MultiplayerMenu/scene.tscn"))

	#map.get_node("Music").play()

func initalize_client_player(player: Player):
	player.cola_collected.connect(func():
		ui.colas_counter = player.colas
	)

func add_player(id: int = 1, name: String = "Poyo", spawn: PlayerSpawn = player_spawn) -> Player:
	var player_scene: PackedScene = load("res://code/players/" + player_name + "/scene.tscn")
	var player: Player = player_scene.instantiate()

	if spawn:
		player.position = spawn.position

	player.name = str(id)
	players.add_child(player)

	return player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
