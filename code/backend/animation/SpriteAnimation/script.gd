extends Node
class_name SpriteAnimation

## Animation metadata for SpriteAnimator

@export var framerate: float = 24
@export var loop: bool = true
@export var loop_frame: int = 0
@export var speed: float = 1
@export var offset: Vector2 = Vector2.ZERO

@onready var sprites: Array[Texture2D]

signal played(old_animation: SpriteAnimation)
signal swapped(new_animation: SpriteAnimation)
signal stopped
signal looped
signal finished
signal new_frame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# does this folder exist? if so, do some silly animation stuff
	var parent: SpriteAnimator = get_parent()
	var path: String = parent.animation_path + "/" + name
	var dir: DirAccess = DirAccess.open(path)

	if !dir:
		print("...There's no folder for this. Whoops.")
		return

	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			var image = Image.load_from_file(path + "/" + file_name)
			var texture = ImageTexture.create_from_image(image)
			print("Loaded! " + path + "/" + file_name)
			sprites.append(texture)

		file_name = dir.get_next()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
