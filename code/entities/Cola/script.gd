extends Entity

func _on_player_collect(player: Player) -> void:
	player.collect_cola(self)
