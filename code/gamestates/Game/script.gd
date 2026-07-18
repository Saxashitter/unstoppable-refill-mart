extends Node2D

@export var player_name: String = "Poyo"
@export var map_name: String = "TestMap"

@onready var ui: GameUI = $GameUI

var map: Map
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map_scene: PackedScene = load("res://code/maps/" + map_name + "/scene.tscn")
	var player_scene: PackedScene = load("res://code/players/" + player_name + "/scene.tscn")

	map = map_scene.instantiate()
	player = player_scene.instantiate()

	add_child(map)

	var player_spawn: PlayerSpawn

	for child in map.spawns.get_children():
		if child is PlayerSpawn:
			player_spawn = child
			break

	if player_spawn:
		player.position = player_spawn.position

	add_child(player)
	player.cola_collected.connect(func():
		ui.colas_counter = player.colas
	)

	#map.get_node("Music").play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
