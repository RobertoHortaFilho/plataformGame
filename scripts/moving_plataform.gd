extends AnimatableBody2D

@export var speed = 2
@onready var target: Sprite2D = $Target

func _ready() -> void:
	target.visible = false
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", target.global_position, speed)
	tween.tween_property(self, "global_position", global_position, speed)
	tween.set_loops()
