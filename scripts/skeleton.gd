extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var front_collision: RayCast2D = $frontCollision
@onready var floor_collision: RayCast2D = $floorCollision

enum enemy_state {
	walk,
	death
}

var state: enemy_state = enemy_state.walk
const SPEED = 20.0
var direction = 1


func _physics_process(delta: float) -> void:
	match state:
		enemy_state.walk:
			walk_state(delta)
		enemy_state.death:
			death_state()
	move_and_slide()
	
func walk_state(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = SPEED * direction
	if front_collision.is_colliding() or not floor_collision.is_colliding():
		direction *= -1
		scale.x *= -1


func death_state():
	pass
	
	

func go_to_walk_state():
	state = enemy_state.walk
	animated_sprite.play("walk")

func go_to_death_state():
	state = enemy_state.death
	animated_sprite.play("death")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	
