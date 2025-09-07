extends Control

@onready var label_2: Label = $VBoxContainer/Label2
@onready var info: LineEdit = $VBoxContainer/Info

signal name_chosen(Name:String)

func registered():
	visible = false
	
func _ready() -> void:
	label_2.visible = false
	
func name_taken():
	label_2.visible = true
	info.text = ""

func _on_info_text_submitted(new_text: String) -> void:
	label_2.visible = false
	emit_signal("name_chosen",new_text)
