extends CanvasLayer

@onready var label: Label = $Label

var total_coins = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.player_collect_x_coins.connect(update_coins)
	label.text = "0"

func update_coins(amount: int):
	total_coins += amount
	label.text = "0" + str(total_coins)
