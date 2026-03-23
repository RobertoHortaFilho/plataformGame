extends CharacterBody2D

class_name Player

enum PlayerState {
	idle,
	walk,
	jump,
	duck,
	fall,
	slide,
	wall,
	swimming,
	dead
}

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var reload_timer: Timer = $ReloadTimer
@onready var hit_box: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var left_wall_detector: RayCast2D = $LeftWallDetector
@onready var right_wall_detector: RayCast2D = $RightWallDetector

@export var max_speed = 80.0
@export var acceleration = 200
@export var deceleration = 200
@export var slide_deceleration = 50
@export var wall_acceleration = 40
@export var water_acceleration = 150
@export var water_speed = 100
var wall_jump_velocity = 200
const JUMP_VELOCITY = -200.0
@export var max_jumps = 2
var jumps_count = 0
var direction = 0

var coins = 0

var status: PlayerState

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
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
		PlayerState.wall:
			wall_state(delta)
		PlayerState.swimming:
			swimming_state(delta)
		PlayerState.dead:
			dead_state(delta)

	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	animation.play("idle")
	jumps_count = 0

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

func go_to_wall_state():
	status = PlayerState.wall
	animation.play("wall")
	velocity = Vector2.ZERO
	jumps_count = 0

func exit_from_slide_state():
	set_tall_colider()

func go_to_dead_state():
	if status == PlayerState.dead:
		return
	status = PlayerState.dead
	animation.play("dead")
	velocity = Vector2.ZERO
	reload_timer.start()

func go_to_swimming_state():
	status = PlayerState.swimming
	animation.play("swimming")
	velocity.y = min(velocity.y, 150)

func idle_state(delta: float):
	apply_gravity(delta)
	move(delta)
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	if velocity.x != 0:
		go_to_walk_state()
		return
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

func walk_state(delta:float):
	apply_gravity(delta)
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
	apply_gravity(delta)
	move(delta)
	if Input.is_action_just_pressed("jump") and can_jump():
		go_to_jump_state()
		return
	if velocity.y > 0:
		go_to_fall_state()

func fall_state(delta: float):
	apply_gravity(delta)
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
	if (left_wall_detector.is_colliding() or right_wall_detector.is_colliding()) && is_on_wall():
		go_to_wall_state()
		return

func duck_state(delta: float):
	apply_gravity(delta)
	update_direction()
	if Input.is_action_just_released("duck"):
		go_to_idle_state()
		exit_from_duck_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		exit_from_duck_state()
		return

func wall_state(delta: float):
	if is_on_floor():
		go_to_idle_state()
		return
	if left_wall_detector.is_colliding():
		animation.flip_h = false
		direction = 1
	elif right_wall_detector.is_colliding():
		animation.flip_h = true
		direction = -1
	else:
		go_to_fall_state()
		return
	velocity.y += wall_acceleration * delta
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		velocity.x = wall_jump_velocity * direction
		return
	

func slide_state(delta: float):
	apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	if velocity.x == 0:
		go_to_duck_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		exit_from_slide_state()
		return
	if Input.is_action_just_released("duck"):
		go_to_walk_state()
		exit_from_slide_state()
		return

func swimming_state(delta: float):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, water_speed * direction, water_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, water_acceleration * delta)
	
	var vertical_direction = Input.get_axis("jump", "duck")
	if vertical_direction:
		velocity.y = move_toward(velocity.y, water_speed * vertical_direction, water_acceleration * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, water_acceleration * delta)

func dead_state(delta: float):
	apply_gravity(delta)

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

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * (delta * 0.5)
	
func can_jump() -> bool:
	return jumps_count < max_jumps
	
func set_small_colider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	hit_box.position.y = 4
	hit_box.scale.y = .5

func set_tall_colider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	hit_box.position.y = 0
	hit_box.scale.y = 1


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()
	

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("LethalArea"):
		go_to_dead_state()
		return
	elif body.is_in_group("Water"):
		go_to_swimming_state()
		return
	elif body.is_in_group("Pickup"):
		on_pick_up_collect(body)


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Water"):
		go_to_jump_state()
		jumps_count = 0
		return

func hit_enemy(area):
	if velocity.y > 0:
		area.get_parent().go_to_death_state()
		go_to_jump_state()
		jumps_count -= 1
		return
	else:
		go_to_dead_state()

func hit_lethal_area():
		go_to_dead_state()

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()

func on_pick_up_collect(body: Node2D):
	coins += 1
	print("coins", coins)
	body.queue_free()
	SignalManager.player_collect_x_coins.emit(1)
