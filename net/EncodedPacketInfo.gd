class_name EncodedPacketInfo

@warning_ignore("unused_signal")
signal packet_signal(packet: Object)

var packet: Object
var attachment: SignalAttachment

func _init(_packet: Object, _attachment: SignalAttachment):
	self.packet = _packet
	self.attachment = _attachment
	pass
