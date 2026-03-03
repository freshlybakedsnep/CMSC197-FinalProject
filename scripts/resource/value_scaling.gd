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
	var key = StatSource.find_key(stat)
	
	var x := tar if from_target else src 	
	var val = x.stats.get(key)
	if val == null:
		match key.to_lower():
			"missing_health":
				val = x.stats["HEALTH_MAX"] - x.stats["HEALTH"]
			_:
				val = x.key
	return val * (multiplier + (mult_gain_per_level * level))
