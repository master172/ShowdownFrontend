extends Control

@onready var label: Label = $VBoxContainer/Label
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

func update_info(Name:String,gender:int,level:int,max:int,value:int):
	label.text = Name + (" ♀" if gender == 0 else " ♂") + "Lv: "+str(level)
	progress_bar.max_value = max
	var tween = get_tree().create_tween()
	tween.tween_property(progress_bar,"value",value,0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
  
