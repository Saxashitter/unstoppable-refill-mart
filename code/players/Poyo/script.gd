extends Player

@onready var state_machine: StateMachine = $Scripts/StateMachine
@onready var animator: AnimationPlayer = $PlayerAnimator
@onready var camera: PlayerCamera = $PlayerCamera
@onready var face: Sprite2D = $Face
@onready var input: PlayerInput = $Scripts/Input
@onready var sounds: Node2D = $Sounds

#@export var current_animation: String:
	#set(string):
		#if not animator: return
		#if current_animation == string: return
#
		#animator.play(string)
		#animator.speed_scale = 1
		#current_animation = string

func _ready():
	super()

	if not is_multiplayer_authority():
		$Scripts.process_mode = Node.PROCESS_MODE_DISABLED
		remove_child(camera)
		# initalize camera!!!
		

func _set_direction(direction: int):
	super(direction)
	if not face: return
	face.flip_h = sprite.flip_h

@rpc("call_local")
func play_animation(anim_name: String):
	if not animator: return
	#if current_animation == string: return

	animator.play(anim_name)
	animator.speed_scale = 1
