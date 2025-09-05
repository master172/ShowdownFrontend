extends Node

@onready var parser: Parser = $Parser
@onready var battle_input: Control = $BattleInput

@export var websocket_url = "ws://localhost:8765"

var socket = WebSocketPeer.new()

signal update_sprites(active:String,opponent:String)
signal update_info_active(Name:String,gender:int,level:int,max_hp:int,hp:int)
signal update_info_opponent(Name:String,gender:int,level:int,max_hp:int,hp:int)

func _ready():
	
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func handle_parsed_repsonse(msg:Dictionary)->void:
	var data_type = parser.get_data_type(msg)
	if data_type == "request":
		if msg["state"]["active_pokemon"]["fainted"] == false:
			battle_input.update_strings(parser.get_attack_list(msg),parser.get_switch_list(msg))
		else:
			battle_input.active_pokemon_faineted(parser.get_switch_list(msg))
			
			
	elif data_type == "turn_end":
		var active_pokemon:String = ""
		var opponent_pokemon:String = ""
		if msg["state"]["active_pokemon"] != null:
			active_pokemon = msg["state"]["active_pokemon"]["species"]
			emit_signal("update_info_active",active_pokemon,parser.get_gender(msg),parser.get_level(msg),parser.get_max_health(msg),parser.get_health(msg))
		if msg["state"]["opponent_active"] != null:
			opponent_pokemon = msg["state"]["opponent_active"]["species"]
			emit_signal("update_info_opponent",opponent_pokemon,parser.get_gender(msg,1),parser.get_level(msg,1),parser.get_max_health(msg,1),parser.get_health(msg,1))
		emit_signal("update_sprites",active_pokemon,opponent_pokemon)
		#battle_input.update_strings(parser.get_attack_list(msg),parser.get_switch_list(msg))
		

func _process(_delta):

	socket.poll()

	var state = socket.get_ready_state()


	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var msg = str(socket.get_packet().get_string_from_utf8())
			print("\nGot data from server: ", msg)
			var parsed_data :Dictionary = parser.parse_response(msg)
			handle_parsed_repsonse(parsed_data)

	elif state == WebSocketPeer.STATE_CLOSING:
		pass


	elif state == WebSocketPeer.STATE_CLOSED:

		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		
		set_process(false)


func _on_battle_input_request_move(move: String) -> void:
	socket.send_text(parser.parse_input(move))
