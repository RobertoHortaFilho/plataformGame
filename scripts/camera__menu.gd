extends Camera2D

@export var speed = 20

func _ready() -> void:
	pass 



func _process(delta: float) -> void:
	self.position.x += speed * delta
