extends Node

const FOREST = preload("uid://dlj5gu0v6yxv4")


func _on_button_start_pressed() -> void:
	SceneTransition.change_transition("res://scene/forest.tscn")
	
func _on_button_options_pressed() -> void:
	pass # Replace with function body.
