extends ValueFormula
class_name ScalingAmount

@export var multiplier := 1.0
@export var stat : StatSource

enum StatSource {
	BASE_HEALTH,
	BASE_ATTACK,
	BASE_DEFENSE,
	BASE_SPEED,
	HEALTH,
	HEALTH_MAX,
	ATTACK,
	DEFENSE,
	SPEED
}

func calculate(src : UnitData) -> int:
	var key = StatSource.find_key(stat)
	var property_name = key.to_lower()
	var val = src.get(property_name)
	return val * multiplier
