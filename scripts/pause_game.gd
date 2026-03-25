extends CanvasLayer

func _ready() -> void:
	$Control/Container/Continue.pressed.connect(resume)
	$Control/Container/MainMenu.pressed.connect(main_menu)
	#$Control.visible = false
	$Control/AnimationPlayer.stop()
	
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("esc"
	) and get_tree().paused == false
	) and !get_tree().current_scene.scene_file_path == "res://scene/inicial_screen.tscn":
		get_tree().paused = true
		#$Control.visible = true
		$Control/AnimationPlayer.play("open")
		

func resume():
	$Control/AnimationPlayer.play_backwards("open")
	await $Control/AnimationPlayer.animation_finished
	get_tree().paused = false
	#$Control.visible = false
	
func main_menu():
	get_tree().paused = false
	$Control.visible = false
	SceneTransition.change_transition("res://scene/inicial_screen.tscn")
