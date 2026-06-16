class_name WebsocketClientThread
extends ISession

var websocketClient: WebsocketClient
var thread: Thread = Thread.new()

var sendQueue_EncodedPacketInfo: ConcurrentArrayList = ConcurrentArrayList.new()
var receiveQueue_DecodedPacketInfo: ConcurrentArrayList = ConcurrentArrayList.new()

func _init(_codec: ICodec, url: String):
	websocketClient = WebsocketClient.new(_codec, url)
	pass

# IComponent-Interface-Implement-Start
func start():
	super.start()
	websocketClient.do_start()
	thread.start(update_thread)
	Log.info("websocket client threads threadId:[{}]", thread.get_id())
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
	return websocketClient.is_activate()

func address() -> String:
	return websocketClient.address()

func send(encodedPacketInfo: EncodedPacketInfo):
	sendQueue_EncodedPacketInfo.add(encodedPacketInfo)
	pass
# ISession-Interface-Implement-End

func update_thread():
	while true:
		var decodedPacketInfo: DecodedPacketInfo = websocketClient.receive()
		if decodedPacketInfo != null:
			receiveQueue_DecodedPacketInfo.add(decodedPacketInfo)
		
		if !sendQueue_EncodedPacketInfo.is_empty():
			var encodedPacketInfo: EncodedPacketInfo = sendQueue_EncodedPacketInfo.pop_front()
			websocketClient.send(encodedPacketInfo)
	pass
