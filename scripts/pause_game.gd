extends CanvasLayer

@onready var ani: AnimationPlayer = $AnimationPlayer


func _ready():
	$Screen/MidleScreen/CenterContainer/VBoxContainer/Resume.pressed.connect(_on_resume)
	$Screen/MidleScreen/CenterContainer/VBoxContainer/Menu.pressed.connect(_on_mainmenu)
	
	
func _process(_delta: float) -> void:
	if (Input.is_action_pressed("esc") and get_tree().paused == false
	) and get_tree().current_scene.name != "InicialScreen":
		get_tree().paused = true
		ani.play("Open")

func _on_resume():
	get_tree().paused = false
	ani.play("Close")
	
func _on_mainmenu():
	get_tree().paused = false
	ani.play("Close")
	SceneTransition.change_transition("res://scene/inicial_screen.tscn")
