extends Node3D

@onready var battle_lost: Control = $BattleLost
@onready var battle_won: Control = $BattleWon

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var web_sockets_connection: Control = $web_sockets_connection

func _on_web_sockets_connection_battle_lost() -> void:
	animation_player.play("Lost")


func _on_web_sockets_connection_battle_won() -> void:
	animation_player.play("Won")


func _on_web_sockets_connection_reset() -> void:
	animation_player.play("Default")


func _on_web_sockets_connection_battle_position(pos: int) -> void:
	battle_lost.tournament_finished(pos)


func _on_web_sockets_connection_tournament_won() -> void:
	battle_won.tournament_won()
