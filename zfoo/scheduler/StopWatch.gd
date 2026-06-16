class_name StopWatch
extends RefCounted

var startTime: int = TimeUtils.current_time_millis()

func cost() -> int:
	return TimeUtils.current_time_millis() - startTime

func cost_seconds() -> float:
	var costSeconds: float = cost() / (TimeUtils.MILLIS_PER_SECOND as float)
	return snappedf(costSeconds, 0.01)

func cost_minutes() -> float:
	var costMinutes: float = cost() / (TimeUtils.MILLIS_PER_MINUTE as float)
	return snappedf(costMinutes, 0.01)
