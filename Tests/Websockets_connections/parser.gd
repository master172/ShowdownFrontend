extends Node
class_name Parser

func parse_input(msg:String) -> String:
	var index:int = 0
	var type:String = "None"
	if msg.begins_with("s"):
		index = int(msg.substr(1))
		type = "switch"
	elif msg.is_valid_int():
		index = int(msg)
		type = "move"
	else:
		return "Invalid move"
	
	return JSON.stringify({"type": type, "index": index})

func get_data_type(msg:Dictionary)->String:
	return msg["type"]
	
func get_attack_list(msg:Dictionary)->Array:
	if msg["type"] == "request":
		return msg["available_moves"]
	else:
		return []

func get_health(msg:Dictionary,pokemon:int=0)->int:
	var poke:String = "active_pokemon" if pokemon == 0 else "opponent_active"
	return msg["state"][poke]["current_hp"]

func get_max_health(msg:Dictionary,pokemon:int=0)->int:
	var poke:String = "active_pokemon" if pokemon == 0 else "opponent_active"
	return msg["state"][poke]["max_hp"]
	
func get_gender(msg:Dictionary,pokemon:int=0)->int:
	var poke:String = "active_pokemon" if pokemon == 0 else "opponent_active"
	return 1 if msg["state"][poke]["gender"] == "male" else 0

func get_level(msg:Dictionary,pokemon:int=0)->int:
	var poke:String = "active_pokemon" if pokemon == 0 else "opponent_active"
	return msg["state"][poke]["level"]

func get_battle_pos(msg:Dictionary)->int:
	return msg["pos"]
	
func get_switch_list(msg:Dictionary)->Array:
	if msg["type"] == "request":
		return msg["available_switches"]
	else:
		return []

func parse_battle_end(msg:Dictionary)->bool:
	var won :bool = msg["won"]
	return won
	
func parse_response(msg:String) -> Dictionary:
	var json = JSON.new()
	var error :Error = json.parse(msg)
	if error != OK:
		push_error("parsing failed of received response")
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", msg, " at line ", json.get_error_line())
		return {}
	else:
		var data_received = json.data
		return data_received

func parse_register(Name:String)->String:
	return JSON.stringify({"type": "register_request", "name": Name})
