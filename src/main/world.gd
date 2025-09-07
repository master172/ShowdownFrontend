extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var web_sockets_connection: Control = $web_sockets_connection

func _on_web_sockets_connection_battle_lost() -> void:
	animation_player.play("Lost")


func _on_web_sockets_connection_battle_won() -> void:
	animation_player.play("Won")


func _on_web_sockets_connection_reset() -> void:
	animation_player.play("Default")
