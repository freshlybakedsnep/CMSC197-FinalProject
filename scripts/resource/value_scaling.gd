extends ValueFormula
class_name ScalingAmount

@export var multiplier := 1.0
@export var mult_gain_per_level := 0.1
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
	SPEED,
	MISSING_HEALTH
}

func calculate(src : UnitData, tar : UnitData) -> float:
	var key = StatSource.find_key(stat).to_lower()
	var val
	val = tar.get(key) if from_target else src.get(key)
	if val == null:
		match key:
			"missing_health":
				val = (tar.health_max - tar.health if from_target 
				else src.health_max - src.health)
	return val * (multiplier + (mult_gain_per_level * level))
