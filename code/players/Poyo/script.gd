extends Player

@onready var state_machine: StateMachine = $Scripts/StateMachine
@onready var animator: AnimationPlayer = $PlayerAnimator
@onready var camera: PlayerCamera = $PlayerCamera
@onready var face: Sprite2D = $Face
@onready var input: PlayerInput = $Scripts/Input
@onready var sounds: Node2D = $Sounds

func _set_direction(direction: int):
	super(direction)
	if not face: return
	face.flip_h = sprite.flip_h
