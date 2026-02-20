extends ValueFormula
class_name FlatAmount

@export var amount := 0

func calculate(src : Entity, tar : Entity) -> int:
	return amount
