extends Node
class_name Map

# the spawn points for objects in the map...
var spawns: Dictionary[String, Array] = {}

@export var music: AudioStreamPlayer

func get_spawns() -> void:
	var spawns_node = get_node("Spawns")

	# get all spawnpoints
	for child in spawns_node.get_children(true):
		if child is Spawn:
			print("Found spawn point for: "+child.object_type)
			if not spawns.has(child.object_type):
				spawns[child.object_type] = []
			spawns[child.object_type].append(child)


func get_spawn_point_for_type(object: Node) -> Node:
	var type = object.get_script().get_global_name()

	if type == "Player" or type == "Poyo": # TODO: UNHARDCODE THIS!!
		type = "Character"

	if spawns.has(type) and spawns[type].size() > 0:
		return spawns[type][0]

	return null
