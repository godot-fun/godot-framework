@abstract
class_name ICodec
extends RefCounted

func encode(_encoded_packet_info: EncodedPacketInfo) -> PackedByteArray:
	return PackedByteArray()

func decode_stream_peer(_stream: StreamPeer) -> DecodedPacketInfo:
	return null

func decode_packet_peer(_stream: PacketPeer) -> DecodedPacketInfo:
	return null
