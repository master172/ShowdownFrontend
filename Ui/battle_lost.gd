extends Control

@onready var info: Label = $VBoxContainer/Info

func _on_button_pressed() -> void:
	get_tree().quit()

func tournament_finished(pos:int):
	info.text = "You finished at position: " + str(pos)
