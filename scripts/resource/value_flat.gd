extends ValueFormula
class_name FlatAmount

@export var amount := 0.0
@export var amount_gain_per_level := 0.0

func calculate(_src : UnitData, _tar : UnitData) -> float:
	return amount + (amount_gain_per_level * level)
