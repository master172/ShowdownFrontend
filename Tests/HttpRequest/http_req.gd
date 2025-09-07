extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2

func _ready():
	var http_request :HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	http_request.request_completed.connect(http_request.queue_free.unbind(4))
	var error :Error = http_request.request("https://play.pokemonshowdown.com/sprites/gen5-back/gardevoirmega.png")
	if error != OK:
		push_error("An error occured during the Http request")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var Img = Image.new()
		var error = Img.load_png_from_buffer(body)
		if error != OK:
			push_error("failed to load png from buffer")
		else:
			var tex:Texture = ImageTexture.create_from_image(Img)
			sprite_2d_2.texture = tex
	else:
		push_error("wtd")
	

func _on_download_completed_back(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	
	if response_code == 200:
		var Img = Image.new()
		var error = Img.load_png_from_buffer(body)
		if error != OK:
			push_error("failed to load png from buffer")
		else:
			var tex:Texture = ImageTexture.create_from_image(Img)
			sprite_2d_2.texture = tex
	else:
		push_error("wtf")
			
func _on_download_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var Img = Image.new()
		var error = Img.load_png_from_buffer(body)
		if error != OK:
			push_error("failed to load png from buffer")
		else:
			var tex:Texture = ImageTexture.create_from_image(Img)
			sprite_2d.texture = tex
