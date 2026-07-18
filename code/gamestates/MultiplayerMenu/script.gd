extends Control

const IP_ADDRESS: String = "localhost"
const PORT: int = 25565

var game: PackedScene = preload("res://code/gamestates/Game/scene.tscn")

func server_connection_signal():
	multiplayer.connected_to_server.disconnect(server_connection_signal)
	get_tree().change_scene_to_packed(game)

func create_multi_instance(server: bool = true):
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

	if server:
		peer.create_server(PORT)
		multiplayer.multiplayer_peer = peer

		multiplayer.peer_connected.connect(func(pid: int):
			print("Connected! "+str(pid)))
		multiplayer.peer_disconnected.connect(func(pid: int):
			print("Disconnected! "+str(pid)))

		get_tree().change_scene_to_packed(game)
		return

	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(server_connection_signal)

func _on_host_pressed() -> void:
	create_multi_instance(true)
	
func _on_join_pressed() -> void:
	create_multi_instance(false)
