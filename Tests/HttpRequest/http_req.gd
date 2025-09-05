extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	var http_request :HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	var error :Error = http_request.request("https://pokeapi.co/api/v2/pokemon/gardevoir")
	if error != OK:
		push_error("An error occured during the Http request")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	var response = json.get_data()

	var front_url = response["sprites"]["front_default"]
	var download_req :HTTPRequest = HTTPRequest.new()
	add_child(download_req)
	download_req.request_completed.connect(_on_download_completed)
	var error:Error = download_req.request(front_url)
	
	if error !=OK:
		push_error("Something went wrong in downloading the front image")
	
	

func _on_download_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var Img = Image.new()
		var error = Img.load_png_from_buffer(body)
		if error != OK:
			push_error("failed to load png from buffer")
		else:
			var tex:Texture = ImageTexture.create_from_image(Img)
			sprite_2d.texture = tex
