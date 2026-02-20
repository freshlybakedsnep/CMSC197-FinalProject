extends ValueFormula
class_name ScalingAmount

@export var multiplier := 1.0
@export var from_target := false

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

func calculate(src : Entity, tar : Entity) -> int:
	var key = StatSource.find_key(stat)
	var property_name = key.to_lower()
	var val = tar.get(property_name) if from_target else src.get(property_name)
	return val * multiplier
