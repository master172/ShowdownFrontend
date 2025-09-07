extends Node

@onready var name_verifier: NameVerifier = $NameVerifier

@export var active_sprite:Sprite3D = null
@export var opponent_sprite:Sprite3D = null

var active_pokemon:String = "" :
	set(val):
		if val != active_pokemon:
			active_pokemon = val
			if val != "":
				get_sprite(active_sprite,val)
		
var opponent_pokemon:String = "":
	set(val):
		if val != opponent_pokemon:
			opponent_pokemon = val
			if val != "":
				get_sprite(opponent_sprite,val)

func get_sprite(sprite:Sprite3D,val:String)->void:
	var http_request:HTTPRequest = HTTPRequest.new()
	http_request.request_completed.connect(_on_request_completed.bind(sprite,val))
	http_request.request_completed.connect(http_request.queue_free.unbind(4))
	add_child(http_request)
	var error :Error = http_request.request("https://pokeapi.co/api/v2/pokemon/"+val)
	if error != OK:
		push_error("An error occured during the Http request")


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray,sprite:Sprite3D,val:String)->void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var parse_err = json.parse(body.get_string_from_utf8())
	
	
	if response_code != 200 or parse_err != OK:
			var mat = name_verifier.find_best_match(val)
			push_warning("Fuzzy matched:", val, "->", mat)
			if mat != "":
				get_sprite(sprite, mat)
			return
	
	var response = json.get_data()
	var front_url = response["sprites"]["back_default"] if sprite == self.active_sprite else response["sprites"]["front_default"]
	
	
	var download_request:HTTPRequest = HTTPRequest.new()
	
	download_request.request_completed.connect(_on_download_completed.bind(sprite))
	download_request.request_completed.connect(download_request.queue_free.unbind(4))
	
	add_child(download_request)
	var error:Error = download_request.request(front_url)
	
	if error !=OK:
		push_error("Something went wrong in downloading the front image")
	
	

func _on_download_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray,sprite:Sprite3D)->void:
	if response_code == 200:
		var Img = Image.new()
		var error = Img.load_png_from_buffer(body)
		if error != OK:
			push_error("failed to load png from buffer")

		else:
			var tex:Texture = ImageTexture.create_from_image(Img)
			sprite.texture = tex



func _on_web_sockets_connection_update_sprites(active: String, opponent: String = "") -> void:
	active_pokemon = active
	if opponent != "":
		opponent_pokemon = opponent


func _on_web_sockets_connection_update_info_active(Name: String, gender: int, level: int, max_hp: int, hp: int) -> void:
	active_sprite.info_component.update_info(Name,gender,level,max_hp,hp)


func _on_web_sockets_connection_update_info_opponent(Name: String, gender: int, level: int, max_hp: int, hp: int) -> void:
	opponent_sprite.info_component.update_info(Name,gender,level,max_hp,hp)


func _on_web_sockets_connection_reset() -> void:
	active_sprite.reset()
	opponent_sprite.reset()
	active_pokemon = ""
	opponent_pokemon = ""
