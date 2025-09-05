extends Control

@onready var label: Label = $Panel/Label

func update_label(t:String)->void:
	label.text = t
