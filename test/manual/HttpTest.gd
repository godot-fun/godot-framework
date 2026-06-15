extends Node


@onready var getRequestButton: Button = $GetRequest
@onready var getRequestChunkButton: Button = $GetRequestChunk
@onready var getRequestFileButton: Button = $GetRequestFile
@onready var postRequestButton: Button = $PostRequest

func _ready() -> void:
	getRequestButton.pressed.connect(pressedGetRequestButton)
	getRequestChunkButton.pressed.connect(pressedGetRequestChunkButton)
	getRequestFileButton.pressed.connect(pressedGetRequestFileButton)
	postRequestButton.pressed.connect(pressedPostRequestButton)
	pass


func pressedGetRequestButton():
	# normal get request
	var response = await HttpHelper.async_get("https://www.baidu.com")
	FileUtils.write_string_to_file("./test.html", response.get_body_string())
	pass

func pressedGetRequestChunkButton():
	# get request in chunk
	var response = await HttpHelper.async_get("https://postman-echo.com/stream/10")
	Log.info(response.get_body_string())
	pass

func pressedGetRequestFileButton():
	var response = await HttpHelper.async_get("https://fsn1-speed.hetzner.com/100MB.bin")
	var file: FileAccess = FileAccess.open("./100MB.bin", FileAccess.WRITE)
	file.store_buffer(response.body)
	pass

func pressedPostRequestButton():
	var response = await HttpHelper.async_post("https://postman-echo.com/post", "{\"name\": \"test\"}")
	Log.info(response.get_body_string())
	pass
