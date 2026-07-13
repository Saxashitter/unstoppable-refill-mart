extends Node
class_name SpriteAnimator

## An animator for Sprite2D classes.
## Every child of this node is a SpriteAnimation class which references valid filenames.
## The first child of the class is the animation that loads upon the _ready() callback.

@export_dir var animation_path: String
@export var sprite: Sprite2D

@onready var _sprite_offset: Vector2 = sprite.offset

var current_frame: int = 0
var current_elapsed: float = 0
var current_animation: SpriteAnimation

var _animations: Dictionary[String, SpriteAnimation] = {}
var _max_frames: int # so we dont gotta keep recalculating

# Play a valid animation
func play(name: String = ""):
	if _animations[name] == null: return

	var animation: SpriteAnimation = _animations[name]
	sprite.texture = animation.sprites[0]
	current_frame = 0
	current_elapsed = 0
	_max_frames = animation.sprites.size() - 1

	if current_animation:
		current_animation.swapped.emit(animation)

	animation.played.emit(current_animation)

	current_animation = animation

func can_progress():
	if current_animation.loop:
		return true

	if current_frame < _max_frames:
		return true

	return false

func _update_frame():
	if not can_progress(): return

	current_frame += 1
	current_elapsed = 0

	if not current_animation.loop and current_frame == _max_frames:
		current_animation.finished.emit()

	if current_frame > current_animation.sprites.size() - 1:
		current_frame = current_animation.loop_frame
		current_animation.looped.emit()
	else:
		current_animation.new_frame.emit()

	sprite.texture = current_animation.sprites[current_frame]

func _update_animation(delta: float):
	if !current_animation: return

	current_elapsed += delta * current_animation.speed

	var seconds_per_frame: float = 1 / current_animation.framerate
	while current_elapsed >= seconds_per_frame:
		_update_frame()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is SpriteAnimation:
			_animations[child.name] = child

	play(get_child(0).name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_animation(delta)
