@tool
extends Node
class_name SpriteAnimation
## Animation metadata for SpriteAnimator
@export var framerate: float = 24
@export var loop: bool = true
@export var loop_frame: int = 0
@export var speed: float = 1
@export var offset: Vector2 = Vector2.ZERO
@onready var sprites: Array[Array] = []
# each element is an Array[Texture2D] — one per entry (overlay layer)
signal played(old_animation: SpriteAnimation)
signal swapped(new_animation: SpriteAnimation)
signal stopped
signal looped
signal finished
signal new_frame(frame: int)

func _ready() -> void:
	var parent: SpriteAnimator = get_parent()
	for entry in parent.entries:
		var layer_frames: Array[Texture2D] = []
		var path: String = entry.path + "/" + name
		var dir: DirAccess = DirAccess.open(path)
		if !dir:
			print("...There's no folder for this. Whoops. (%s)" % path)
			sprites.append(layer_frames)
			continue
		var i: int = 0
		while ResourceLoader.exists(path + "/" + str(i) + ".png"):
			var texture: Texture2D = load(path + "/" + str(i) + ".png")
			layer_frames.append(texture)
			i += 1
		sprites.append(layer_frames)

func _process(delta: float) -> void:
	pass
