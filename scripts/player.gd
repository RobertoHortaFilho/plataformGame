extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	duck
}

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const SPEED = 60.0
const JUMP_VELOCITY = -200.0
@export var max_jumps = 2
var jumps_count = 0
var direction = 0

var status: PlayerState

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * (delta * 0.5)

	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.duck:
			duck_state()

	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	animation.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	animation.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	animation.play("jump")
	velocity.y = JUMP_VELOCITY
	jumps_count += 1

func exit_from_jump_state():
	jumps_count = 0

func go_to_duck_state():
	status = PlayerState.duck
	animation.play("duck")
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3

func exit_from_duck_state():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0

func idle_state():
	move()
	if velocity.x != 0:
		go_to_walk_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func jump_state():
	move()
	if Input.is_action_just_pressed("jump") and jumps_count < max_jumps:
		go_to_jump_state()
		return

	if is_on_floor():
		exit_from_jump_state()
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func duck_state():
	update_direction()
	if Input.is_action_just_released("duck"):
		go_to_idle_state()
		exit_from_duck_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		exit_from_duck_state()
		return

func update_direction():
	direction = Input.get_axis("left", "right")
	if direction > 0:
		animation.flip_h = false
	elif  direction < 0:
		animation.flip_h = true

func move():
	update_direction()
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
