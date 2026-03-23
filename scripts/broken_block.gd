extends StaticBody2D

@onready var area_2d: Area2D = $Area2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var broken_timer: Timer = $BrokenTimer
@onready var reset_timer: Timer = $ResetTimer

var start_position: Vector2
var is_broken = false

func _ready() -> void:
	broken_timer.timeout.connect(on_broken_block)
	reset_timer.timeout.connect(on_reset)
	start_position = global_position


func _process(delta: float) -> void:
	if is_broken:
		return;
	var bodies = area_2d.get_overlapping_bodies()
	for body in bodies:
		var player: CharacterBody2D = body
		if player.is_on_floor():
			is_broken = true
			animated_sprite.play("broken")
			broken_timer.start()

func on_broken_block():
	animated_sprite.play("destroy")
	collision_layer = 0
	var position_final = global_position + (Vector2.DOWN * 40)
	var fall_tween = create_tween()
	fall_tween.set_trans(Tween.TRANS_QUAD)
	fall_tween.set_ease(Tween.EASE_IN)
	fall_tween.tween_property(self, "global_position", position_final, 0.3)
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(animated_sprite, "modulate:a", 0, 0.3)
	reset_timer.start()

func on_reset():
	animated_sprite.play("default")
	collision_layer = 1
	is_broken = false
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(animated_sprite, "modulate:a", 1, 0.3)
	var create_block_tween = create_tween()
	create_block_tween.set_trans(Tween.TRANS_QUART)
	create_block_tween.set_ease(Tween.EASE_IN_OUT)
	create_block_tween.tween_property(self, "global_position", start_position, 0.3)
	
