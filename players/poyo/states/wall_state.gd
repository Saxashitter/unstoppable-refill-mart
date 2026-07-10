extends State
class_name WallState

@onready var animator: AnimationPlayer = $"../../Animator"
@onready var movement: Movement = $"../../Movement"

@export var pushback: float = 20

var direction: int = 1

func enter(character: Player):
	direction = 1
	if character.get_wall_normal().x < 0:
		direction = -1

	character.set_facing(direction)
	character.velocity.x = 0

	animator.play("fall_loop")
	animator.speed_scale = 1

	for sprite: Sprite2D in character.sprites:
		sprite.rotation = 0

func physics_process(character: Player, delta: float):
	movement.apply_gravity(character, delta / 2)
	character.velocity.x = -pushback * direction

	character.move_and_slide()

	if !character.is_on_wall() or character.is_on_floor():
		character.velocity.x = 0
		return states["IdleState"]

	if !Input.is_action_just_pressed("jump"): return

	character.velocity.x = states["IdleState"].run_speed * direction
	states["IdleState"].jump(character)
	return "IdleState"
