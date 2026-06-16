class_name RateLimitUtils
extends Object


static var last_limit_second_1: int = 0
static var last_limit_second_2: int = 0
static var last_limit_second_3: int = 0

static func limit_second_1() -> bool:
	var ticks := Time.get_ticks_msec()

	if ticks - last_limit_second_1 < TimeUtils.MILLIS_PER_SECOND:
		return true
	
	last_limit_second_1 = ticks
	return false


static func limit_second_2() -> bool:
	var ticks := Time.get_ticks_msec()

	if ticks - last_limit_second_2 < 2 * TimeUtils.MILLIS_PER_SECOND:
		return true
	
	last_limit_second_2 = ticks
	return false


static func limit_second_3() -> bool:
	var ticks := Time.get_ticks_msec()

	if ticks - last_limit_second_3 < 3 * TimeUtils.MILLIS_PER_SECOND:
		return true

	last_limit_second_3 = ticks
	return false
