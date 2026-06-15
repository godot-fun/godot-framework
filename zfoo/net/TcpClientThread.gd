class_name TcpClientThread
extends ISession

var tcpClient: TcpClient
var thread: Thread = Thread.new()

var sendQueue_EncodedPacketInfo: ConcurrentArrayList = ConcurrentArrayList.new()
var receiveQueue_DecodedPacketInfo: ConcurrentArrayList = ConcurrentArrayList.new()

func _init(_codec: ICodec, hostAndPort: String):
	tcpClient = TcpClient.new(_codec, hostAndPort)
	pass

# IComponent-Interface-Implement-Start
func start() -> void:
	super.start()
	tcpClient.do_start()
	thread.start(update_thread)
	Log.info("tcp client threads threadId:[{}]", thread.get_id())
	pass

func update() -> void:
	if receiveQueue_DecodedPacketInfo.is_empty():
		return
	var decodedPacketInfo: DecodedPacketInfo = receiveQueue_DecodedPacketInfo.pop_front()
	Router.at_receiver(decodedPacketInfo)
	pass
# IComponent-Interface-Implement-End

# ISession-Interface-Implement-Start
func is_activate() -> bool:
	return tcpClient.is_activate()

func address() -> String:
	return tcpClient.address()

func send(encodedPacketInfo: EncodedPacketInfo) -> void:
	sendQueue_EncodedPacketInfo.add(encodedPacketInfo)
	pass
# ISession-Interface-Implement-End

func update_thread():
	while true:
		var decodedPacketInfo: DecodedPacketInfo = tcpClient.receive()
		if decodedPacketInfo != null:
			receiveQueue_DecodedPacketInfo.add(decodedPacketInfo)
		
		if !sendQueue_EncodedPacketInfo.is_empty():
			var encodedPacketInfo: EncodedPacketInfo = sendQueue_EncodedPacketInfo.pop_front()
			tcpClient.send(encodedPacketInfo)
	pass
