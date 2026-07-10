extends Node
class_name SceneTransition

signal finished

@export var play_leaving: bool = false
@export var kill_on_finished: bool = true

@onready var animator: AnimationPlayer = $AnimationPlayer

var playing: bool = false

func _ready() -> void:
	if playing: return
	play(play_leaving)

func play(leaving: bool = false):
	playing = true
	if leaving:
		animator.play("leaving")
	else:
		animator.play("entering")


func _on_finished(anim_name: StringName) -> void:
	if !playing: return

	if kill_on_finished:
		queue_free()

	finished.emit()
