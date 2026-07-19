extends Control

@onready var player_name: LineEdit = $VBoxContainer/PlayerName
@onready var ip_text: LineEdit = $VBoxContainer/IP
@onready var port_text: LineEdit = $VBoxContainer/Port

const IP_ADDRESS: String = "localhost"
const PORT: int = 25565

var game: PackedScene = preload("res://code/gamestates/Game/scene.tscn")

func server_connection_signal():
	multiplayer.connected_to_server.disconnect(server_connection_signal)
	get_tree().change_scene_to_packed(game)

func create_multi_instance(server: bool = true):
	# set player name...
	var new_name: String = player_name.text.strip_edges()
	var ip_address: String = IP_ADDRESS
	var port: int = PORT

	var port_string: String = port_text.text.strip_edges()
	var ip_string: String = ip_text.text.strip_edges()

	if ip_string != "":
		ip_address = ip_string

	if port_string != "" and int(port_string) != null:
		port = int(port_string)

	if new_name != "":
		GameData.player_name = new_name

	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

	if server:
		peer.create_server(port)
		multiplayer.multiplayer_peer = peer

		multiplayer.peer_connected.connect(func(pid: int):
			print("Connected! "+str(pid)))
		multiplayer.peer_disconnected.connect(func(pid: int):
			print("Disconnected! "+str(pid)))

		get_tree().change_scene_to_packed(game)
		return

	peer.create_client(ip_address, port)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(server_connection_signal)

func _on_host_pressed() -> void:
	create_multi_instance(true)
	
func _on_join_pressed() -> void:
	create_multi_instance(false)
