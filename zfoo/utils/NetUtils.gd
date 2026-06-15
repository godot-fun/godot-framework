class_name NetUtils
extends Object

const LOCAL_LOOPBACK_IP: String = "127.0.0.1"
const PORT_RANGE_MIN: int = 1024
const PORT_RANGE_MAX: int = 65535

static func local_host() -> String:
	return IP.resolve_hostname(OS.get_environment("COMPUTERNAME"), IP.Type.TYPE_IPV4)
