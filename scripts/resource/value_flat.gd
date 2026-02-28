extends ValueFormula
class_name FlatAmount

@export var amount := 0

func calculate(_src : Entity, _tar : Entity) -> float:
	return amount
