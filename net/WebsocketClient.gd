class_name WebsocketClient
extends ISession


var client: WebSocketPeer = WebSocketPeer.new()
var codec: ICodec = null

var url: String
var started: bool = false

var current_status: WebSocketPeer.State = WebSocketPeer.STATE_CLOSED

signal on_closed
signal on_closing
signal on_connecting
signal on_open

func _init(_codec: ICodec, _url: String):
	self.codec = _codec
	self.url = _url
	pass

# IComponent-Interface-Implement-Start
func start() -> void:
	super.start()
	do_start()
	pass

func update() -> void:
	if started:
		Router.at_receiver(receive())
		return
	pass

func do_start() -> void:
	started = true
	client.connect_to_url(url)
	pass
# IComponent-Interface-Implement-End

# ISession-Interface-Implement-Start
func is_activate() -> bool:
	var status := client.get_ready_state()
	return true if status == WebSocketPeer.STATE_OPEN else false

func address() -> String:
	return url

func send(encodedPacketInfo: EncodedPacketInfo):
	client.send(codec.encode(encodedPacketInfo), client.WRITE_MODE_BINARY)
	pass
# ISession-Interface-Implement-End

func receive() -> DecodedPacketInfo:
	client.poll()
	var status := client.get_ready_state()
	match status:
		WebSocketPeer.STATE_CLOSED:
			# Auto Reconnect
			client.close()
			client.connect_to_url(url)
			if current_status != WebSocketPeer.STATE_CLOSED:
				current_status = WebSocketPeer.STATE_CLOSED
				Log.error("status none and reconnect [{}]", url)
				gdf.callable_deferred(func() -> void: on_closed.emit())
		WebSocketPeer.STATE_CLOSING:
			if current_status != WebSocketPeer.STATE_CLOSING:
				current_status = WebSocketPeer.STATE_CLOSING
				Log.error("status error [{}]", url)
				gdf.callable_deferred(func() -> void: on_closing.emit())
		WebSocketPeer.STATE_CONNECTING:
			if current_status != WebSocketPeer.STATE_CONNECTING:
				current_status = WebSocketPeer.STATE_CONNECTING
				Log.info("status connecting [{}]", url)
				gdf.callable_deferred(func() -> void: on_connecting.emit())
		WebSocketPeer.STATE_OPEN:
			if current_status != WebSocketPeer.STATE_OPEN:
				current_status = WebSocketPeer.STATE_OPEN
				Log.info("status connected [{}]", url)
				gdf.callable_deferred(func() -> void: on_open.emit())
			var decodedPacketInfo := codec.decode_packet_peer(client)
			return decodedPacketInfo
		_:
			Log.info("websocket client unknown")
	return null
