extends Player

@onready var state_machine: StateMachine = $StateMachine
@onready var animator: SpriteAnimator = $BodyAnimator
@onready var camera: PlayerCamera = $PlayerCamera
@onready var face: Sprite2D = $Face

func _set_direction(direction: int):
	super(direction)
	face.flip_h = sprite.flip_h
