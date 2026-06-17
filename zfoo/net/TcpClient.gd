class_name TcpClient
extends ISession

var client: StreamPeerTCP = StreamPeerTCP.new()
var codec: ICodec = null

var host: String
var port: int
var started: bool = false

var current_status: StreamPeerTCP.Status = StreamPeerTCP.STATUS_NONE

signal on_error
signal on_connecting
signal on_connected

func _init(_codec: ICodec, hostAndPort: String):
	self.codec = _codec
	var splits := hostAndPort.split(":")
	self.host = splits[0]
	self.port = splits[1].to_int()
	pass


# IComponent-Interface-Implement-Start
func start() -> void:
	super.start()
	do_start()
	pass

func update() -> void:
	if started:
		Router.at_receiver(receive())
	pass

func do_start() -> void:
	client.big_endian = true
	started = true
	client.connect_to_host(host, port)
	pass
# IComponent-Interface-Implement-End

# ISession-Interface-Implement-Start
func is_activate() -> bool:
	var status := client.get_status()
	return true if status == StreamPeerTCP.STATUS_CONNECTED else false

func address() -> String:
	return StringUtils.format("{}:{}", host, port)

func send(encodedPacketInfo: EncodedPacketInfo) -> void:
	client.put_data(codec.encode(encodedPacketInfo))
	pass
# ISession-Interface-Implement-End

func receive() -> DecodedPacketInfo:
	client.poll()
	var status := client.get_status()
	match status:
		StreamPeerTCP.STATUS_NONE:
			# Auto Reconnect
			client.disconnect_from_host()
			client.connect_to_host(host, port)
			if current_status != StreamPeerTCP.STATUS_NONE:
				current_status = StreamPeerTCP.STATUS_NONE
				Log.error("status none and reconnect [{}:{}]", host, port)
		StreamPeerTCP.STATUS_ERROR:
			# Auto Reconnect
			client.disconnect_from_host()
			client.connect_to_host(host, port)
			if current_status != StreamPeerTCP.STATUS_ERROR:
				current_status = StreamPeerTCP.STATUS_ERROR
				Log.error("status error [{}:{}]", host, port)
				gdf.callable_deferred(func() -> void: on_error.emit())
		StreamPeerTCP.STATUS_CONNECTING:
			if current_status != StreamPeerTCP.STATUS_CONNECTING:
				current_status = StreamPeerTCP.STATUS_CONNECTING
				Log.info("status connecting [{}:{}]", host, port)
				gdf.callable_deferred(func() -> void: on_connecting.emit())
		StreamPeerTCP.STATUS_CONNECTED:
			if current_status != StreamPeerTCP.STATUS_CONNECTED:
				current_status = StreamPeerTCP.STATUS_CONNECTED
				Log.info("status connected [{}:{}]", host, port)
				gdf.callable_deferred(func() -> void: on_connected.emit())
			var decodedPacketInfo := codec.decode_stream_peer(client)
			return decodedPacketInfo
		_:
			Log.info("tcp client unknown")
	return null
