@tool
extends Node
class_name SpriteAnimator

## An animator for Sprite2D classes.
## Every child of this node is a SpriteAnimation class which references valid filenames.
## The first child of the class is the animation that loads upon the _ready() callback.

@export var entries: Array[SpriteAnimationEntry]
@export var editor_animation: SpriteAnimation:
	set(value):
		editor_animation = value
		if not Engine.is_editor_hint(): return
		if entries.is_empty(): return
		editor_frame = max(0, min(editor_frame, _frame_count(editor_animation) - 1))
		play(value.name)
@export var editor_frame: int:
	set(value):
		if not Engine.is_editor_hint(): return
		if not current_animation: return
		editor_frame = max(0, min(value, _frame_count(current_animation) - 1))
		_apply_frame(current_animation, editor_frame)

var current_frame: int = 0
var current_elapsed: float = 0
var current_animation: SpriteAnimation
var _animations: Dictionary[String, SpriteAnimation] = {}
var _max_frames: int # so we dont gotta keep recalculating
var _sprites: Array[Sprite2D] = []
var _sprite_offsets: Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_sprites.clear()
	_sprite_offsets.clear()
	for entry in entries:
		var s: Sprite2D = get_node(entry.sprite) as Sprite2D
		_sprites.append(s)
		_sprite_offsets.append(s.offset if s else Vector2.ZERO)
	for child in get_children():
		if child is SpriteAnimation:
			_animations[child.name] = child
	play(get_child(0).name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_update_animation(delta)

func get_animation(name: String) -> SpriteAnimation:
	return _animations[name]

# Longest frame count across all overlay layers, in case entries have mismatched lengths
func _frame_count(animation: SpriteAnimation) -> int:
	var count: int = 0
	for layer in animation.sprites:
		count = max(count, layer.size())
	return count

func _apply_frame(animation: SpriteAnimation, frame: int) -> void:
	for k in range(_sprites.size()):
		var s: Sprite2D = _sprites[k]
		if not s: continue

		var layer: Array = animation.sprites[k]
		if frame < layer.size():
			s.texture = layer[frame]
			s.visible = true
		else:
			s.visible = false

	animation.new_frame.emit(current_frame)

# Play a valid animation
func play(name: String = "") -> void:
	if not _animations.has(name): return
	var animation: SpriteAnimation = _animations[name]

	for k in range(_sprites.size()):
		var s: Sprite2D = _sprites[k]
		if not s: continue
		s.offset = _sprite_offsets[k] + animation.offset

	current_frame = 0
	current_elapsed = 0
	_max_frames = _frame_count(animation) - 1
	_apply_frame(animation, current_frame)
	if current_animation:
		current_animation.swapped.emit(animation)
	animation.played.emit(current_animation)
	current_animation = animation

func can_progress() -> bool:
	if current_animation.loop:
		return true
	if current_frame < _max_frames:
		return true
	return false

func _update_frame() -> void:
	if not can_progress(): return
	current_frame += 1
	current_elapsed = 0
	if not current_animation.loop and current_frame == _max_frames:
		current_animation.finished.emit()
	if current_frame > _max_frames:
		current_frame = current_animation.loop_frame
		current_animation.looped.emit()
	else:
		current_animation.new_frame.emit(current_frame)
	_apply_frame(current_animation, current_frame)

func _update_animation(delta: float) -> void:
	if !current_animation: return
	current_elapsed += delta * current_animation.speed
	var seconds_per_frame: float = 1 / current_animation.framerate
	while current_elapsed >= seconds_per_frame:
		_update_frame()
