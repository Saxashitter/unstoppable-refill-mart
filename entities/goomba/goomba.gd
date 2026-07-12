extends Enemy
class_name Goomba

@export var speed: float = 50
@export var facing: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var collider: CollisionShape2D = $Collider
@onready var left_edge: RayCast2D = $LeftEdge
@onready var right_edge: RayCast2D = $RightEdge

@onready var kill_timer: Timer = $"Timer"

var in_death_anim: bool = false

func on_died(source: Entity = null):
	if in_death_anim: return
	in_death_anim = true

	scale.y /= 2
	$Stomp.play()
	velocity = Vector2.ZERO
	kill_timer.start(0.5)
	kill_timer.timeout.connect(func():
		queue_free()
	)

func move_goomba(_facing: int = facing, _speed: float = speed):
	sprite.flip_h = _facing == 1
	velocity.x = speed * _facing

func _ready() -> void:
	move_goomba()

func _physics_process(delta: float) -> void:
	move_and_slide()

	velocity += get_gravity() * delta
	if is_on_floor():
		if !left_edge.is_colliding():
			move_goomba(1)

		if !right_edge.is_colliding():
			move_goomba(-1)

	if is_on_wall():
		move_goomba(facing * -1)


func _on_hurtbox_touch(area: Area2D) -> void:
	var player: Player = area.get_parent() as Player
	if player == null: return

	if player.velocity.y < 0: return
	if player.is_on_floor(): return
	if in_death_anim: return

	player.velocity.y *= -1
	hurt()
