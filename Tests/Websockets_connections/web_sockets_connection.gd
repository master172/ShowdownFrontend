extends Node

@onready var line_edit: LineEdit = $MainContainer/LineEdit
@onready var button: Button = $MainContainer/Button
@onready var rich_text_label: RichTextLabel = $MainContainer/RichTextLabel
@onready var parser: Parser = $Parser

@onready var battle_input: Control = $BattleInput

@export var websocket_url = "ws://localhost:8765"

var socket = WebSocketPeer.new()

func _ready():
	
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		rich_text_label.text += "Unable to connect"
		set_process(false)

func handle_parsed_repsonse(msg:Dictionary)->void:
	var data_type = parser.get_data_type(msg)
	if data_type == "request":
		battle_input.update_strings(parser.get_attack_list(msg),parser.get_switch_list(msg))
		
func _process(_delta):

	socket.poll()

	var state = socket.get_ready_state()


	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var msg = str(socket.get_packet().get_string_from_utf8())
			print("\nGot data from server: ", msg)
			var parsed_data :Dictionary = parser.parse_response(msg)
			rich_text_label.text += ("\nGot data from server: "+ str(parsed_data))
			handle_parsed_repsonse(parsed_data)

	elif state == WebSocketPeer.STATE_CLOSING:
		pass


	elif state == WebSocketPeer.STATE_CLOSED:

		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		rich_text_label.text += ("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		
		set_process(false)


func _on_button_pressed() -> void:
	socket.send_text(parser.parse_input(line_edit.text))
	line_edit.clear()
