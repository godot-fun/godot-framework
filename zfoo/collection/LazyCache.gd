class_name LazyCache
extends RefCounted


class Cache:
	var key: Variant
	var value: Variant
	var expire_time: int = 0

enum RemovalCause {
	EXPLICIT,
	REPLACED,
	EXPIRED,
	SIZE
}

const DEFAULT_BACK_PRESSURE_FACTOR: float = 0.13

var maximum_size: int
var back_pressure_size: int
var expire_after_access_millis: int
var expire_check_interval_millis: int
var min_expire_time: int
var expire_check_time: int
var cache_map: Dictionary[Variant, Cache] = {}
var remove_listener: Callable = func(_removes: Array[Cache], _cause: RemovalCause) -> void:
	pass

func _init(_maximum_size: int, _expire_after_access_millis: int, _expire_check_interval_millis: int):
	assert(_maximum_size >= 1)
	assert(_expire_after_access_millis >= 0)
	assert(_expire_check_interval_millis >= 0)

	maximum_size = _maximum_size
	back_pressure_size = max(maximum_size, int(maximum_size * (1.0 + DEFAULT_BACK_PRESSURE_FACTOR)))
	expire_after_access_millis = _expire_after_access_millis
	expire_check_interval_millis = max(1, _expire_check_interval_millis)
	min_expire_time = TimeUtils.now()
	expire_check_time = TimeUtils.now()
	pass

func put(key: Variant, value: Variant) -> Variant:
	check_expire()
	var cache := Cache.new()
	cache.key = key
	cache.value = value
	cache.expire_time = TimeUtils.now() + expire_after_access_millis
	var old_cache = cache_map.get(key, null)
	cache_map[key] = cache
	if old_cache != null:
		remove_listener.call([old_cache], RemovalCause.REPLACED)
	check_maximum_size()
	return old_cache

func get_value(key: Variant) -> Variant:
	check_expire()
	var cache = cache_map.get(key, null)
	if cache == null:
		return null
	if cache.expire_time < TimeUtils.now():
		remove_for_cause(key, RemovalCause.EXPIRED)
		return null
	cache.expire_time = TimeUtils.now() + expire_after_access_millis
	return cache.value

func remove(key: Variant) -> void:
	check_expire()
	remove_for_cause(key, RemovalCause.EXPLICIT)
	pass

func size() -> int:
	check_expire()
	return cache_map.size()

# ---------------------------------------
func remove_for_cause(key: Variant, cause: RemovalCause) -> void:
	if key == null:
		return
	var cache = cache_map.get(key, null)
	if cache != null:
		cache_map.erase(key)
		remove_listener.call([cache], cause)
	pass

func remove_for_cause_list(caches: Array[Cache], cause: RemovalCause) -> void:
	if caches.is_empty():
		return
	var removed: Array[Cache] = []
	for cache in caches:
		if cache_map.erase(cache.key):
			removed.append(cache)
	if !removed.is_empty():
		remove_listener.call(removed, cause)
	pass

func check_maximum_size() -> void:
	if cache_map.size() > back_pressure_size:
		var all_caches := cache_map.values()
		all_caches.sort_custom(func(a, b): return a.expire_time < b.expire_time)
		var remove_count := cache_map.size() - maximum_size
		var remove_list := all_caches.slice(0, remove_count)
		remove_for_cause_list(remove_list, RemovalCause.SIZE)
	pass


func check_expire() -> void:
	var now: int = TimeUtils.now()
	if now > expire_check_time:
		expire_check_time = now + expire_check_interval_millis
		if now > min_expire_time:
			var min_timestamp: int = NumberUtils.INT64_MAX
			var remove_list: Array[Cache] = []
			for cache in cache_map.values():
				if cache.expire_time < now:
					remove_list.append(cache)
				elif cache.expire_time < min_timestamp:
					min_timestamp = cache.expire_time
			remove_for_cause_list(remove_list, RemovalCause.EXPIRED)
			if min_timestamp < NumberUtils.INT64_MAX:
				min_expire_time = min_timestamp
	pass
