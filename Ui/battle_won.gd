extends Control

@onready var info: Label = $VBoxContainer/Info

func tournament_won():
	info.text = "Congratulations you won the tournament"
