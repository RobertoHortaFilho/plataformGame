extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	duck,
	fall,
	slide,
	dead
}

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var max_speed = 80.0
@export var acceleration = 200
@export var deceleration = 200
@export var slide_deceleration = 50
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
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.dead:
			dead_state(delta)

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
	set_small_colider()

func exit_from_duck_state():
	set_tall_colider()

func go_to_fall_state():
	status = PlayerState.fall
	animation.play("fall")

func go_to_slide_state():
	status = PlayerState.slide
	animation.play("slide")
	set_small_colider()

func exit_to_slide_state():
	set_tall_colider()

func go_to_dead_state():
	status = PlayerState.dead
	animation.play("dead")
	velocity = Vector2.ZERO



func idle_state(delta: float):
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

func walk_state(delta:float):
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	if ! is_on_floor():
		go_to_fall_state()
		return
	if Input.is_action_pressed("duck"):
		go_to_slide_state()
		return

func jump_state(delta: float):
	move(delta)
	if Input.is_action_just_pressed("jump") and can_jump():
		go_to_jump_state()
		return
	if velocity.y > 0:
		go_to_fall_state()

func fall_state(delta: float):
	move(delta)
	if is_on_floor():
		exit_from_jump_state()
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return
	if Input.is_action_just_pressed("jump") and can_jump():
		go_to_jump_state()
		return

func duck_state(_delta: float):
	update_direction()
	if Input.is_action_just_released("duck"):
		go_to_idle_state()
		exit_from_duck_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		exit_from_duck_state()
		return

func slide_state(delta: float):
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	if velocity.x == 0:
		go_to_duck_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
	if Input.is_action_just_released("duck"):
		go_to_walk_state()
		return

func dead_state(_delta: float):
	pass

func update_direction():
	direction = Input.get_axis("left", "right")
	if direction > 0:
		animation.flip_h = false
	elif  direction < 0:
		animation.flip_h = true

func move(delta: float):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func can_jump() -> bool:
	return jumps_count < max_jumps
	
func set_small_colider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3

func set_tall_colider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0


func _on_hitbox_area_entered(area: Area2D) -> void:
	if velocity.y > 0:
		#inimigo morre
		area.get_parent().queue_free()
		go_to_jump_state()
		jumps_count -= 1
		return
	else:
		go_to_dead_state()
