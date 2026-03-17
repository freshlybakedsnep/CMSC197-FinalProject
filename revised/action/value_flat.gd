extends ValueFormula
class_name ValueFlat

@export var amount := 0.0
@export var amount_gain_per_level := 0.0

func calculate(_src : EntityData, _tar : EntityData) -> float:
	return amount + (amount_gain_per_level * level)
