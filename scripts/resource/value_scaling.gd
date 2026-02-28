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

func calculate(src : Entity, tar : Entity) -> float:
	var key = StatSource.find_key(stat)
	var property_name = key.to_lower()
	var val
	if property_name.contains("base"):
		val = tar.data.get(property_name) if from_target else src.data.get(property_name)
	else: 
		val = tar.get(property_name) if from_target else src.get(property_name)
	return val * multiplier
