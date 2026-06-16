@abstract
class_name ISession
extends IComponent

func is_activate() -> bool:
	return true

func address() -> String:
	return StringUtils.EMPTY

func send(_encodedPacketInfo: EncodedPacketInfo) -> void:
	pass
