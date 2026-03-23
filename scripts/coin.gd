extends StaticBody2D

@onready var ima: Area2D = $Ima
var target_position = self.global_position
var speed = 90

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bodies = ima.get_overlapping_bodies()
	if bodies.size():
		var player: CharacterBody2D = bodies[0]
		target_position = player.global_position
	else:
		target_position = self.global_position
	position.x = move_toward(position.x, target_position.x, speed * delta)
	position.y = move_toward(position.y, target_position.y, speed * delta)
