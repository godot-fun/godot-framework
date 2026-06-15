class_name IdUtils
extends Object

static var _local_id: int = 0
static func local_id() -> int:
	_local_id += 1
	return _local_id


static var _uuid: int = 0
static var _mutex: Mutex = Mutex.new()
static func uuid() -> int:
	_mutex.lock()
	_uuid = _uuid + 1
	var id: int = _uuid
	_mutex.unlock()
	return id
