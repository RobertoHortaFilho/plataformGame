extends CharacterBody2D

const BONE = preload("uid://ch7w3702vhjq2")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var front_collision: RayCast2D = $frontCollision
@onready var floor_collision: RayCast2D = $floorCollision
@onready var player_detector: RayCast2D = $playerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition
@onready var bone_path_detector: RayCast2D = $bonePathDetector

enum enemy_state {
	walk,
	attack,
	death
}

var state: enemy_state = enemy_state.walk
const SPEED = 20.0
var direction = 1
var can_throw = true


func _physics_process(delta: float) -> void:
	match state:
		enemy_state.walk:
			walk_state(delta)
		enemy_state.attack:
			attack_state(delta)
		enemy_state.death:
			death_state()
	move_and_slide()
	
func walk_state(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	if animated_sprite.frame == 3 or animated_sprite.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	if front_collision.is_colliding() or not floor_collision.is_colliding():
		direction *= -1
		scale.x *= -1
	if player_detector.is_colliding() and !bone_path_detector.is_colliding():
		go_to_attack_state()
		return

func attack_state(_delta: float):
	if animated_sprite.frame == 2 and can_throw:
		can_throw = false
		throw_bone()

func death_state():
	pass
	
	

func go_to_walk_state():
	state = enemy_state.walk
	animated_sprite.play("walk")

func go_to_attack_state():
	velocity = Vector2.ZERO
	state = enemy_state.attack
	animated_sprite.play("attack")
	can_throw = true

func go_to_death_state():
	state = enemy_state.death
	animated_sprite.play("death")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO

func throw_bone():
	var new_bone = BONE.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(self.direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		go_to_walk_state()
		return
